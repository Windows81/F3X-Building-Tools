-- ROBLOX Object Properties =========
-- [Name] Building Tools by F3X
-- [ClassName] LocalScript
-- [Parent] Building Tools
-- ==================================

------------------------------------------
-- Create references to important objects
------------------------------------------
Services = {
	["Workspace"] = game:GetService( "Workspace" );
	["Players"] = game:GetService( "Players" );
	["Lighting"] = game:GetService( "Lighting" );
	["Teams"] = game:GetService( "Teams" );
	["Debris"] = game:GetService( "Debris" );
	["MarketplaceService"] = game:GetService( "MarketplaceService" );
	["JointsService"] = game.JointsService;
	["BadgeService"] = game:GetService( "BadgeService" );
	["RunService"] = game:GetService( "RunService" );
	["ContentProvider"] = game:GetService( "ContentProvider" );
	["TeleportService"] = game:GetService( "TeleportService" );
	["SoundService"] = game:GetService( "SoundService" );
	["InsertService"] = game:GetService( "InsertService" );
	["CollectionService"] = game:GetService( "CollectionService" );
	["UserInputService"] = game:GetService( "UserInputService" );
	["GamePassService"] = game:GetService( "GamePassService" );
	["StarterPack"] = game:GetService( "StarterPack" );
	["StarterGui"] = game:GetService( "StarterGui" );
};

Tool = script.Parent;
Player = Services.Players.LocalPlayer;
Mouse = nil;

dark_slanted_rectangle = "http://www.roblox.com/asset/?id=127774197";
light_slanted_rectangle = "http://www.roblox.com/asset/?id=127772502";

------------------------------------------
-- Load external dependencies
------------------------------------------
RbxUtility = LoadLibrary( "RbxUtility" );
Services.ContentProvider:Preload( dark_slanted_rectangle );
Services.ContentProvider:Preload( light_slanted_rectangle );

------------------------------------------
-- Define functions that are depended-upon
------------------------------------------
function _findTableOccurrences( haystack, needle )
	-- Returns the positions of instances of `needle` in table `haystack`
	local positions = {};

	-- Add any indexes from `haystack` that have `needle`
	for index, value in pairs( haystack ) do
		if value == needle then
			table.insert( positions, index );
		end;
	end;

	return positions;
end;

function _getCollectionInfo( part_collection )
	-- Returns the size and position of collection of parts `part_collection`

	-- Get the corners
	local corners = {};

	local table_insert = table.insert;

	for _, Part in pairs( part_collection ) do

		-- Create shortcuts to certain things that are expensive to call constantly
		local PartCFrame = Part.CFrame;
		local PartSize = Part.Size / 2;
		local size_x, size_y, size_z = PartSize.x, PartSize.y, PartSize.z;

		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( size_x, size_y, size_z ) ) );
		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( -size_x, size_y, size_z ) ) );
		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( size_x, -size_y, size_z ) ) );
		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( size_x, size_y, -size_z ) ) );
		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( -size_x, size_y, -size_z ) ) );
		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( -size_x, -size_y, size_z ) ) );
		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( size_x, -size_y, -size_z ) ) );
		table_insert( corners, PartCFrame:toWorldSpace( CFrame.new( -size_x, -size_y, -size_z ) ) );

	end;

	-- Get the extents
	local x, y, z = {}, {}, {};

	for _, Corner in pairs( corners ) do
		table_insert( x, Corner.x );
		table_insert( y, Corner.y );
		table_insert( z, Corner.z );
	end;

	local x_min, y_min, z_min = math.min( unpack( x ) ),
								math.min( unpack( y ) ),
								math.min( unpack( z ) );

	local x_max, y_max, z_max = math.max( unpack( x ) ),
								math.max( unpack( y ) ),
								math.max( unpack( z ) );

	-- Get the size between the extents
	local x_size, y_size, z_size = 	x_max - x_min,
									y_max - y_min,
									z_max - z_min;

	local Size = Vector3.new( x_size, y_size, z_size );

	-- Get the centroid of the collection of points
	local Position = CFrame.new( 	x_min + ( x_max - x_min ) / 2,
									y_min + ( y_max - y_min ) / 2,
									z_min + ( z_max - z_min ) / 2 );

	-- Return the size of the collection of parts
	return Size, Position;
end;

function _round( number, places )
	-- Returns `number` rounded to the number of decimal `places`
	-- (from lua-users)

	local mult = 10 ^ ( places or 0 );

	return math.floor( number * mult + 0.5 ) / mult;

end

function _cloneTable( source )
	-- Returns a deep copy of table `source`

	-- Get a copy of `source`'s metatable, since the hacky method
	-- we're using to copy the table doesn't include its metatable
	local source_mt = getmetatable( source );

	-- Return a copy of `source` including its metatable
	return setmetatable( { unpack( source ) }, source_mt );
end;

------------------------------------------
-- Create data containers
------------------------------------------
ActiveKeys = {};

Options = setmetatable( {

	["_options"] = {
		["Tool"] = nil,
		["PreviousTool"] = nil
	}

}, {

	__newindex = function ( self, key, value )

		-- Do different special things depending on `key`
		if key == "Tool" then

			-- If it's a different tool than the current one
			if self.Tool ~= value then

				-- Run (if existent) the old tool's `Unequipped` listener
				if Options.Tool and Options.Tool.Listeners.Unequipped then
					Options.Tool.Listeners.Unequipped();
				end;

				rawget( self, "_options" ).PreviousTool = Options.Tool;
				rawget( self, "_options" ).Tool = nil;

				-- Replace the current handle with `value.Handle`
				local Handle = Tool:FindFirstChild( "Handle" );
				if Handle then
					Handle.Parent = nil;
				end;
				value.Handle.Parent = Tool;

				-- Adjust the grip for the new handle
				Tool.Grip = value.Grip;

				-- Run (if existent) the new tool's `Equipped` listener
				if value.Listeners.Equipped then
					value.Listeners.Equipped();
				end;

			end;
		end;

		-- Set the value normally to `self._options`
		rawget( self, "_options" )[key] = value;

	end;

	-- Get any options from `self._options` instead of `self` directly
	__index = function ( self, key )
		return rawget( self, "_options" )[key];
	end;

} );

-- Keep some state data
clicking = false;
selecting = false;
click_x, click_y = 0, 0;
override_selection = false;

SelectionBoxes = {};
SelectionExistenceListeners = {};
SelectionBoxColor = BrickColor.new( "Cyan" );

Dragger = nil;

function updateSelectionBoxColor()
	-- Updates the color of the selectionboxes
	for _, SelectionBox in pairs( SelectionBoxes ) do
		SelectionBox.Color = SelectionBoxColor;
	end;
end;

Selection = {

	["Items"] = {};

	-- Provide events to listen to changes in the selection
	["Changed"] = RbxUtility.CreateSignal();
	["ItemAdded"] = RbxUtility.CreateSignal();
	["ItemRemoved"] = RbxUtility.CreateSignal();

	-- Provide a method to get an item's index in the selection
	["find"] = function ( self, Needle )

		-- Look through all the selected items and return the matching item's index
		for item_index, Item in pairs( self.Items ) do
			if Item == Needle then
				return item_index;
			end;
		end;

		-- Otherwise, return `nil`

	end;

	-- Provide a method to add items to the selection
	["add"] = function ( self, NewPart )

		-- Make sure `NewPart` isn't already in the selection
		if #_findTableOccurrences( self.Items, NewPart ) > 0 then
			return false;
		end;

		-- Insert it into the selection
		table.insert( self.Items, NewPart );

		-- Add its SelectionBox
		SelectionBoxes[NewPart] = Instance.new( "SelectionBox", Player.PlayerGui );
		SelectionBoxes[NewPart].Name = "BTSelectionBox";
		SelectionBoxes[NewPart].Color = SelectionBoxColor;
		SelectionBoxes[NewPart].Adornee = NewPart;

		-- Remove any target selection box focus
		if NewPart == Options.TargetBox.Adornee then
			Options.TargetBox.Adornee = nil;
		end;

		-- Make sure to remove the item from the selection when it's deleted
		SelectionExistenceListeners[NewPart] = NewPart.AncestryChanged:connect( function ( Object, NewParent )
			if NewParent == nil then
				Selection:remove( NewPart );
			end;
		end );

		-- Provide a reference to the last item added to the selection (i.e. NewPart)
		self.Last = NewPart;

		-- Fire events
		self.ItemAdded:fire( NewPart );
		self.Changed:fire();

	end;

	-- Provide a method to remove items from the selection
	["remove"] = function ( self, Item )

		-- Make sure selection item `Item` exists
		if not self:find( Item ) then
			return false;
		end;

		-- Remove `Item`'s SelectionBox
		local SelectionBox = SelectionBoxes[Item];
		if SelectionBox then
			SelectionBox:Destroy();
		end;
		SelectionBoxes[Item] = nil;

		-- Delete the item from the selection
		table.remove( self.Items, self:find( Item ) );

		-- If it was logged as the last item, change it
		if self.Last == Item then
			self.Last = ( #self.Items > 0 ) and self.Items[#self.Items] or nil;
		end;

		-- Delete the existence listeners of the item
		SelectionExistenceListeners[Item]:disconnect();
		SelectionExistenceListeners[Item] = nil;

		-- Fire events
		self.ItemRemoved:fire( Item );
		self.Changed:fire();

	end;

	-- Provide a method to clear the selection
	["clear"] = function ( self )

		-- Go through all the items in the selection and call `self.remove` on them
		for _, Item in pairs( _cloneTable( self.Items ) ) do
			self:remove( Item );
		end;

	end;

};

Tools = {};

------------------------------------------
-- Paint tool
------------------------------------------

-- Create the main container for this tool
Tools.Paint = {};

-- Define the color of the tool
Tools.Paint.Color = BrickColor.new( "Really red" );

-- Define options
Tools.Paint.Options = setmetatable( {

	["_options"] = {
		["Color"] = BrickColor.new( "Institutional white" ),
		["PaletteGUI"] = nil
	}

}, {

	-- Get the option from `self._options` instead of `self` directly
	__index = function ( self, key )
		return rawget( self, "_options" )[key];
	end;

	-- Let's do some special stuff if certain options are touched
	__newindex = function ( self, key, value )

		if key == "Color" then

			-- Mark the appropriate color in the palette
			if self.PaletteGUI then

				-- Clear any mark on any other color button from the palette
				for _, PaletteColorButton in pairs( self.PaletteGUI.Container.Palette:GetChildren() ) do
					PaletteColorButton.Text = "";
				end;

				-- Mark the right color button in the palette
				self.PaletteGUI.Container.Palette[value.Name].Text = "X";

			end;

			-- Change the color of selected items
			for _, Item in pairs( Selection.Items ) do
				Item.BrickColor = value;
			end;

		end;

		-- Set the option normally
		rawget( self, "_options" )[key] = value;

	end;

} );

-- Add listeners
Tools.Paint.Listeners = {};

Tools.Paint.Listeners.Equipped = function ()
	showPalette();
end;

Tools.Paint.Listeners.Unequipped = function ()
	hidePalette();
end;

Tools.Paint.Listeners.Button1Up = function ()

	-- Make sure that they clicked on one of the items in their selection
	-- (and they weren't multi-selecting)
	if Selection:find( Mouse.Target ) and not selecting and not selecting then

		override_selection = true;

		-- Paint all of the selected items `Tools.Paint.Options.Color`
		if Tools.Paint.Options.Color then
			for _, Item in pairs( Selection.Items ) do
				Item.BrickColor = Tools.Paint.Options.Color;
			end;
		end;

	end;

end;

-- Create the handle
Tools.Paint.Handle = RbxUtility.Create "Part" {
	Name = "Handle";
	Locked = true;
	BrickColor = Tools.Paint.Color;
	FormFactor = Enum.FormFactor.Custom;
	Size = Vector3.new( 0.8, 0.8, 0.8 );
	TopSurface = Enum.SurfaceType.Smooth;
	BottomSurface = Enum.SurfaceType.Smooth;
};
RbxUtility.Create "Decal" {
	Parent = Tools.Paint.Handle;
	Face = Enum.NormalId.Front;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Paint.Handle;
	Face = Enum.NormalId.Back;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Paint.Handle;
	Face = Enum.NormalId.Left;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Paint.Handle;
	Face = Enum.NormalId.Right;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Paint.Handle;
	Face = Enum.NormalId.Top;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Paint.Handle;
	Face = Enum.NormalId.Bottom;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};

-- Set the grip for the handle
Tools.Paint.Grip = CFrame.new( 0, 0, 0.4 );

function showPalette()
	-- Reveals a color palette

	-- Create the GUI container
	local PaletteGUI = Instance.new( "ScreenGui", Player.PlayerGui );
	PaletteGUI.Name = "BTPaintGUI";

	-- Register the GUI
	Tools.Paint.Options.PaletteGUI = PaletteGUI;

	RbxUtility.Create "Frame" {
		Parent = PaletteGUI;
		Name = "Container";
		Active = true;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 0, 0, 230 );
		Size = UDim2.new( 0, 205, 0, 230 );
		Draggable = true;
	};
	RbxUtility.Create "Frame" {
		Parent = PaletteGUI.Container;
		Name = "Title";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 0, 20 );
	};

	RbxUtility.Create "Frame" {
		Parent = PaletteGUI.Container.Title;
		Name = "ColorBar";
		BackgroundColor3 = BrickColor.new( "Really red" ).Color;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, -3 );
		Size = UDim2.new( 1, -5, 0, 2 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = PaletteGUI.Container.Title;
		Name = "Label";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 10, 0, 1 );
		Size = UDim2.new( 1, -10, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "PAINT TOOL";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextXAlignment = Enum.TextXAlignment.Left;
		TextStrokeTransparency = 0;
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextWrapped = true;
	};

	RbxUtility.Create "TextLabel" {
		Parent = PaletteGUI.Container.Title;
		Name = "F3XSignature";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 10, 0, 1 );
		Size = UDim2.new( 1, -10, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size14;
		Text = "F3X";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextXAlignment = Enum.TextXAlignment.Right;
		TextStrokeTransparency = 0.9;
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextWrapped = true;
	};

	-- Create the frame that will contain the colors
	local PaletteFrame = Instance.new( "Frame", PaletteGUI.Container );
	PaletteFrame.Name = "Palette";
	PaletteFrame.BackgroundColor3 = Color3.new( 0, 0, 0 );
	PaletteFrame.Transparency = 1;
	PaletteFrame.Size = UDim2.new( 0, 205, 0, 205 );
	PaletteFrame.Position = UDim2.new( 0, 5, 0, 20 );

	-- Insert the colors
	for palette_index = 0, 63 do

		-- Get BrickColor `palette_index` from the palette
		local Color = BrickColor.palette( palette_index );

		-- Calculate the row and column in the 8x8 grid
		local row = ( palette_index - ( palette_index % 8 ) ) / 8;
		local column = palette_index % 8;

		-- Create the button
		local ColorButton = Instance.new( "TextButton", PaletteFrame );
		ColorButton.Name = Color.Name;
		ColorButton.BackgroundColor3 = Color.Color;
		ColorButton.Size = UDim2.new( 0, 20, 0, 20 );
		ColorButton.Text = "";
		ColorButton.TextStrokeTransparency = 0.75;
		ColorButton.Font = Enum.Font.ArialBold;
		ColorButton.FontSize = Enum.FontSize.Size18;
		ColorButton.TextColor3 = Color3.new( 1, 1, 1 );
		ColorButton.TextStrokeColor3 = Color3.new( 0, 0, 0 );
		ColorButton.Position = UDim2.new( 0, column * 25 + 5, 0, row * 25 + 5 );
		ColorButton.BorderSizePixel = 0;

		-- Make the button change the `Color` option
		ColorButton.MouseButton1Click:connect( function ()
			Tools.Paint.Options.Color = Color;
		end );

	end;

end;

function hidePalette()

	if Tools.Paint.Options.PaletteGUI then
		Tools.Paint.Options.PaletteGUI:Destroy();
		Tools.Paint.Options.PaletteGUI = nil;
	end;

end;

------------------------------------------
-- Move tool
------------------------------------------

-- Create the main container for this tool
Tools.Move = {};

-- Define the color of the tool
Tools.Move.Color = BrickColor.new( "Deep orange" );

-- Keep a container for the handles and other temporary stuff
Tools.Move.Temporary = {
	["Handles"] = nil;
	["BoundaryBox"] = nil;
	["Connections"] = {};
	["MovementListeners"] = {};
	["PreviousSelectionBoxColor"] = nil;
};

-- Keep options in a container too
Tools.Move.Options = {
	["increment"] = 1;
	["axes"] = "global";
};

-- Keep internal state data in its own container
Tools.Move.State = {
	["previous_distance"] = 0;
	["moving"] = false;
	["dragging"] = false;
};

-- Add listeners
Tools.Move.Listeners = {};

Tools.Move.Listeners.Equipped = function ()

	-- Make sure the tool is actually being equipped (because this is the default tool)
	if not Mouse then
		return;
	end;

	-- Change the color of selection boxes temporarily
	Tools.Move.Temporary.PreviousSelectionBoxColor = SelectionBoxColor;
	SelectionBoxColor = Tools.Move.Color;
	updateSelectionBoxColor();

	Tools.Move.Temporary.BoundaryBox = Tools.Move:createBoundaryBox();

	-- Show the GUI
	Tools.Move:showGUI();

	table.insert( Tools.Move.Temporary.Connections, Selection.Changed:connect( function ()
		Tools.Move.Temporary.BoundaryBox = Tools.Move:updateBoundaryBox( Tools.Move.Temporary.BoundaryBox, Selection.Items );
		Tools.Move:updateGUI();
		Tools.Move:updateAxes();
	end ) );
	table.insert( Tools.Move.Temporary.Connections, Selection.ItemRemoved:connect( function ( Item )
		if Tools.Move.Temporary.MovementListeners[Item] then
			Tools.Move.Temporary.MovementListeners[Item]:disconnect();
			Tools.Move.Temporary.MovementListeners[Item] = nil;
		end;
	end ) );
	Tools.Move.Temporary.BoundaryUpdater = coroutine.create( function ()
		while true do
			wait( 0.1 );
			Tools.Move.Temporary.BoundaryBox = Tools.Move:updateBoundaryBox( Tools.Move.Temporary.BoundaryBox, Selection.Items );
			Tools.Move:updateGUI();
		end;
	end );
	coroutine.resume( Tools.Move.Temporary.BoundaryUpdater );

	-- Create 3D movement handles
	Tools.Move.Temporary.Handles = Instance.new( "Handles", Player.PlayerGui );
	Tools.Move.Temporary.Handles.Name = "BTMovementHandles";
	Tools.Move.Temporary.Handles.Adornee = nil;
	Tools.Move.Temporary.Handles.Style = Enum.HandlesStyle.Resize;
	Tools.Move.Temporary.Handles.Color = Tools.Move.Color;

	Tools.Move.Temporary.Connections.LastSwitchHandler = Mouse.Button2Down:connect( function ()

		-- Make sure that the target is part of the selection already
		if Selection:find( Mouse.Target ) then
			Selection.Last = Mouse.Target;
			Tools.Move:updateAxes();
		end;

	end );

	-- Update BoundaryBox's shape/position to reflect current selection
	Tools.Move.Temporary.BoundaryBox = Tools.Move:updateBoundaryBox( Tools.Move.Temporary.BoundaryBox, Selection.Items );
	Tools.Move:updateGUI();

	table.insert( Tools.Move.Temporary.Connections, Tools.Move.Temporary.Handles.MouseButton1Down:connect( function ()
		Tools.Move.State.moving = true;
		Tools.Move.State.distance_moved = 0;
		Tools.Move.State.MoveStart = {};
		Tools.Move.State.MoveStartAnchors = {};
		Tools.Move.State.MoveStartCollision = {};
		for _, Item in pairs( Selection.Items ) do
			Tools.Move.State.MoveStart[Item] = Item.CFrame;
			Tools.Move.State.MoveStartAnchors[Item] = Item.Anchored;
			Item.Anchored = true;
		end;
		override_selection = true;

		-- Let's listen to `Mouse`'s `Button1Up` instead of the handle's because the latter's only fires when
		-- the button is released /on/ the handle (and that's not always the case)
		local ReleaseListener;
		ReleaseListener = Mouse.Button1Up:connect( function ()
			override_selection = true;

			ReleaseListener:disconnect();
			Tools.Move.State.moving = false;
			Tools.Move.State.MoveStart = {};

			-- Reset each item's anchor state to its original
			for _, Item in pairs( Selection.Items ) do
				Item.Anchored = Tools.Move.State.MoveStartAnchors[Item];
				Item:MakeJoints();
			end;

			Tools.Move.State.MoveStartAnchors = {};
		end );
	end ) );

	table.insert( Tools.Move.Temporary.Connections, Tools.Move.Temporary.Handles.MouseDrag:connect( function ( face, drag_distance )

		-- Calculate which multiple of the increment to use based on the current drag distance's
		-- proximity to their nearest upper and lower multiples

		local difference = drag_distance % Tools.Move.Options.increment;

		local lower_degree = drag_distance - difference;
		local upper_degree = drag_distance - difference + Tools.Move.Options.increment;

		local lower_degree_proximity = math.abs( drag_distance - lower_degree );
		local upper_degree_proximity = math.abs( drag_distance - upper_degree );

		if lower_degree_proximity <= upper_degree_proximity then
			drag_distance = lower_degree;
		else
			drag_distance = upper_degree;
		end;

		local increase = drag_distance;

		Tools.Move.State.distance_moved = drag_distance;
		Tools.Move:updateGUI();

		-- Increment the position of each selected item in the direction of `face`
		for _, Item in pairs( Selection.Items ) do

			-- Remove any joints connected with `Item` so that it can freely move
			Item:BreakJoints();

			-- Update the position of `Item` depending on the type of axes that is currently set
			if face == Enum.NormalId.Top then
				if Tools.Move.Options.axes == "global" then
					Item.CFrame = CFrame.new( Tools.Move.State.MoveStart[Item].p ):toWorldSpace( CFrame.new( 0, increase, 0 ) ) * CFrame.Angles( Tools.Move.State.MoveStart[Item]:toEulerAnglesXYZ() );
				elseif Tools.Move.Options.axes == "local" then
					Item.CFrame = Tools.Move.State.MoveStart[Item]:toWorldSpace( CFrame.new( 0, increase, 0 ) );
				elseif Tools.Move.Options.axes == "last" then
					Item.CFrame = Tools.Move.State.MoveStart[Selection.Last]:toWorldSpace( CFrame.new( 0, increase, 0 ) ):toWorldSpace( Tools.Move.State.MoveStart[Item]:toObjectSpace( Tools.Move.State.MoveStart[Selection.Last] ):inverse() );
				end;
			
			elseif face == Enum.NormalId.Bottom then
				if Tools.Move.Options.axes == "global" then
					Item.CFrame = CFrame.new( Tools.Move.State.MoveStart[Item].p ):toWorldSpace( CFrame.new( 0, -increase, 0 ) ) * CFrame.Angles( Tools.Move.State.MoveStart[Item]:toEulerAnglesXYZ() );
				elseif Tools.Move.Options.axes == "local" then
					Item.CFrame = Tools.Move.State.MoveStart[Item]:toWorldSpace( CFrame.new( 0, -increase, 0 ) );
				elseif Tools.Move.Options.axes == "last" then
					Item.CFrame = Tools.Move.State.MoveStart[Selection.Last]:toWorldSpace( CFrame.new( 0, -increase, 0 ) ):toWorldSpace( Tools.Move.State.MoveStart[Item]:toObjectSpace( Tools.Move.State.MoveStart[Selection.Last] ):inverse() );
				end;

			elseif face == Enum.NormalId.Front then
				if Tools.Move.Options.axes == "global" then
					Item.CFrame = CFrame.new( Tools.Move.State.MoveStart[Item].p ):toWorldSpace( CFrame.new( 0, 0, -increase ) ) * CFrame.Angles( Tools.Move.State.MoveStart[Item]:toEulerAnglesXYZ() );
				elseif Tools.Move.Options.axes == "local" then
					Item.CFrame = Tools.Move.State.MoveStart[Item]:toWorldSpace( CFrame.new( 0, 0, -increase ) );
				elseif Tools.Move.Options.axes == "last" then
					Item.CFrame = Tools.Move.State.MoveStart[Selection.Last]:toWorldSpace( CFrame.new( 0, 0, -increase ) ):toWorldSpace( Tools.Move.State.MoveStart[Item]:toObjectSpace( Tools.Move.State.MoveStart[Selection.Last] ):inverse() );
				end;

			elseif face == Enum.NormalId.Back then
				if Tools.Move.Options.axes == "global" then
					Item.CFrame = CFrame.new( Tools.Move.State.MoveStart[Item].p ):toWorldSpace( CFrame.new( 0, 0, increase ) ) * CFrame.Angles( Tools.Move.State.MoveStart[Item]:toEulerAnglesXYZ() );
				elseif Tools.Move.Options.axes == "local" then
					Item.CFrame = Tools.Move.State.MoveStart[Item]:toWorldSpace( CFrame.new( 0, 0, increase ) );
				elseif Tools.Move.Options.axes == "last" then
					Item.CFrame = Tools.Move.State.MoveStart[Selection.Last]:toWorldSpace( CFrame.new( 0, 0, increase ) ):toWorldSpace( Tools.Move.State.MoveStart[Item]:toObjectSpace( Tools.Move.State.MoveStart[Selection.Last] ):inverse() );
				end;

			elseif face == Enum.NormalId.Right then
				if Tools.Move.Options.axes == "global" then
					Item.CFrame = CFrame.new( Tools.Move.State.MoveStart[Item].p ):toWorldSpace( CFrame.new( increase, 0, 0 ) ) * CFrame.Angles( Tools.Move.State.MoveStart[Item]:toEulerAnglesXYZ() );
				elseif Tools.Move.Options.axes == "local" then
					Item.CFrame = Tools.Move.State.MoveStart[Item]:toWorldSpace( CFrame.new( increase, 0, 0 ) );
				elseif Tools.Move.Options.axes == "last" then
					Item.CFrame = Tools.Move.State.MoveStart[Selection.Last]:toWorldSpace( CFrame.new( increase, 0, 0 ) ):toWorldSpace( Tools.Move.State.MoveStart[Item]:toObjectSpace( Tools.Move.State.MoveStart[Selection.Last] ):inverse() );
				end;

			elseif face == Enum.NormalId.Left then
				if Tools.Move.Options.axes == "global" then
					Item.CFrame = CFrame.new( Tools.Move.State.MoveStart[Item].p ):toWorldSpace( CFrame.new( -increase, 0, 0 ) ) * CFrame.Angles( Tools.Move.State.MoveStart[Item]:toEulerAnglesXYZ() );
				elseif Tools.Move.Options.axes == "local" then
					Item.CFrame = Tools.Move.State.MoveStart[Item]:toWorldSpace( CFrame.new( -increase, 0, 0 ) );
				elseif Tools.Move.Options.axes == "last" then
					Item.CFrame = Tools.Move.State.MoveStart[Selection.Last]:toWorldSpace( CFrame.new( -increase, 0, 0 ) ):toWorldSpace( Tools.Move.State.MoveStart[Item]:toObjectSpace( Tools.Move.State.MoveStart[Selection.Last] ):inverse() );
				end;

			end;

		end;
	end ) );

	Tools.Move:updateAxes();

end;

Tools.Move.updateGUI = function ( self )
	
	if self.Temporary.OptionsGUI then
		local GUI = self.Temporary.OptionsGUI.Container;

		if #Selection.Items > 0 then

			-- Look for identical numbers in each axis
			local position_x, position_y, position_z =  nil, nil, nil;
			for item_index, Item in pairs( Selection.Items ) do

				-- Set the first values for the first item
				if item_index == 1 then
					position_x, position_y, position_z = _round( Item.Position.x, 2 ), _round( Item.Position.y, 2 ), _round( Item.Position.z, 2 );

				-- Otherwise, compare them and set them to `nil` if they're not identical
				else
					if position_x ~= _round( Item.Position.x, 2 ) then
						position_x = nil;
					end;
					if position_y ~= _round( Item.Position.y, 2 ) then
						position_y = nil;
					end;
					if position_z ~= _round( Item.Position.z, 2 ) then
						position_z = nil;
					end;
				end;

			end;

			-- If each position along each axis is the same, display that number; otherwise, display "*"
			GUI.Info.Center.X.TextLabel.Text = position_x and tostring( position_x ) or "*";
			GUI.Info.Center.Y.TextLabel.Text = position_y and tostring( position_y ) or "*";
			GUI.Info.Center.Z.TextLabel.Text = position_z and tostring( position_z ) or "*";

			GUI.Info.Visible = true;
		else
			GUI.Info.Visible = false;
		end;

		if self.State.distance_moved then
			GUI.Changes.Text.Text = "moved " .. tostring( self.State.distance_moved ) .. " studs";
			GUI.Changes.Position = GUI.Info.Visible and UDim2.new( 0, 5, 0, 165 ) or UDim2.new( 0, 5, 0, 100 );
			GUI.Changes.Visible = true;
		else
			GUI.Changes.Text.Text = "";
			GUI.Changes.Visible = false;
		end;
	end;

end;

Tools.Move.Listeners.Button1Down = function ()

	if not Mouse.Target or ( Mouse.Target:IsA( "BasePart" ) and Mouse.Target.Locked ) then
		return;
	end;

	if not Selection:find( Mouse.Target ) then
		Selection:clear();
		Selection:add( Mouse.Target );
	end;

	Tools.Move.State.dragging = true;

	override_selection = true;

	Tools.Move.Temporary.Dragger = Instance.new( "Dragger" );

	Tools.Move.Temporary.Dragger:MouseDown( Mouse.Target, Mouse.Target.Position - Mouse.Hit.p, Selection.Items );

	Tools.Move.Temporary.DraggerConnection = Mouse.Button1Up:connect( function ()

		override_selection = true;

		Tools.Move.Temporary.DraggerConnection:disconnect();
		Tools.Move.Temporary.DraggerConnection = nil;

		if not Tools.Move.Temporary.Dragger then
			return;
		end;

		Tools.Move.Temporary.Dragger:MouseUp();

		Tools.Move.State.dragging = false;

		Tools.Move.Temporary.Dragger:Destroy();
		Tools.Move.Temporary.Dragger = nil;

	end );

end;

Tools.Move.Listeners.Move = function ()

	if not Tools.Move.Temporary.Dragger then
		return;
	end;

	override_selection = true;

	Tools.Move.Temporary.Dragger:MouseMove( Mouse.UnitRay );

end;

Tools.Move.Listeners.Unequipped = function ()

	-- Hide the options GUI
	Tools.Move:hideGUI();

	-- Restore the original selection box color
	SelectionBoxColor = Tools.Move.Temporary.PreviousSelectionBoxColor;
	updateSelectionBoxColor();

	-- Disconnect any temporary connections
	for connection_index, Connection in pairs( Tools.Move.Temporary.Connections ) do
		Connection:disconnect();
		Tools.Move.Temporary.Connections[connection_index] = nil;
	end;
	for connection_index, Connection in pairs( Tools.Move.Temporary.MovementListeners ) do
		Connection:disconnect();
		Tools.Move.Temporary.MovementListeners[connection_index] = nil;
	end;

	-- Dispose of the coroutine that updates the boundary
	Tools.Move.Temporary.BoundaryUpdater = nil;

	-- Remove the boundary box
	if Tools.Move.Temporary.BoundaryBox then
		Tools.Move.Temporary.BoundaryBox:Destroy();
		Tools.Move.Temporary.BoundaryBox = nil;
	end;

	-- Remove the handles
	if Tools.Move.Temporary.Handles then
		Tools.Move.Temporary.Handles:Destroy();
		Tools.Move.Temporary.Handles = nil;
	end;

	if Tools.Move.Temporary.DraggerConnection then
		Tools.Move.Temporary.DraggerConnection:disconnect();
		Tools.Move.Temporary.DraggerConnection = nil;
	end;

	if Tools.Move.Temporary.Dragger then
		Tools.Move.Temporary.Dragger:Destroy();
		Tools.Move.Temporary.Dragger = nil;
	end;

	if Tools.Move.Temporary.AdorneeWatcher then
		Tools.Move.Temporary.AdorneeWatcher:disconnect();
		Tools.Move.Temporary.AdorneeWatcher = nil;
	end;

end;

-- Create the handle
Tools.Move.Handle = RbxUtility.Create "Part" {
	Name = "Handle";
	Locked = true;
	BrickColor = BrickColor.new( "Deep orange" );
	FormFactor = Enum.FormFactor.Custom;
	Size = Vector3.new( 0.8, 0.8, 0.8 );
	TopSurface = Enum.SurfaceType.Smooth;
	BottomSurface = Enum.SurfaceType.Smooth;
};

RbxUtility.Create "Decal" {
	Parent = Tools.Move.Handle;
	Face = Enum.NormalId.Front;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Move.Handle;
	Face = Enum.NormalId.Back;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Move.Handle;
	Face = Enum.NormalId.Left;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Move.Handle;
	Face = Enum.NormalId.Right;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Move.Handle;
	Face = Enum.NormalId.Top;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Move.Handle;
	Face = Enum.NormalId.Bottom;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};

-- Set the grip for the handle
Tools.Move.Grip = CFrame.new( 0, 0, 0.4 );

Tools.Move.showGUI = function ( self )
	-- Creates and shows the move tool's options panel

	local GUIRoot = Instance.new( "ScreenGui", Player.PlayerGui );
	GUIRoot.Name = "BTMoveToolGUI";

	self.Temporary.OptionsGUI = GUIRoot;

	RbxUtility.Create "Frame" {
		Parent = GUIRoot;
		Name = "Container";
		Active = true;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 0, 0, 280 );
		Size = UDim2.new( 0, 245, 0, 90 );
		Draggable = true;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container;
		Name = "AxesOption";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 0, 0, 30 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.AxesOption;
		Name = "Global";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 45, 0, 0 );
		Size = UDim2.new( 0, 70, 0, 25 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.AxesOption.Global;
		Name = "SelectedIndicator";
		BackgroundColor3 = Color3.new( 1, 1, 1 );
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 6, 0, -2 );
		Size = UDim2.new( 1, -5, 0, 2 );
		BackgroundTransparency = ( self.Options.axes == "global" ) and 0 or 1;
	};

	RbxUtility.Create "TextButton" {
		Parent = GUIRoot.Container.AxesOption.Global;
		Name = "Button";
		Active = true;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 0 );
		Size = UDim2.new( 1, -10, 1, 0 );
		ZIndex = 2;
		Text = "";
		TextTransparency = 1;

		-- Change the axis type option when the button is clicked
		[RbxUtility.Create.E "MouseButton1Down"] = function ()
			self.Options.axes = "global";
			self:updateAxes();
			GUIRoot.Container.AxesOption.Global.SelectedIndicator.BackgroundTransparency = 0;
			GUIRoot.Container.AxesOption.Global.Background.Image = dark_slanted_rectangle;
			GUIRoot.Container.AxesOption.Local.SelectedIndicator.BackgroundTransparency = 1;
			GUIRoot.Container.AxesOption.Local.Background.Image = light_slanted_rectangle;
			GUIRoot.Container.AxesOption.Last.SelectedIndicator.BackgroundTransparency = 1;
			GUIRoot.Container.AxesOption.Last.Background.Image = light_slanted_rectangle;
		end;
	};

	RbxUtility.Create "ImageLabel" {
		Parent = GUIRoot.Container.AxesOption.Global;
		Name = "Background";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Image = ( self.Options.axes == "global" ) and dark_slanted_rectangle or light_slanted_rectangle;
		Size = UDim2.new( 1, 0, 1, 0 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.AxesOption.Global;
		Name = "Label";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "GLOBAL";
		TextColor3 = Color3.new( 1, 1, 1 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.AxesOption;
		Name = "Local";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 110, 0, 0 );
		Size = UDim2.new( 0, 70, 0, 25 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.AxesOption.Local;
		Name = "SelectedIndicator";
		BackgroundColor3 = Color3.new( 1, 1, 1 );
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 6, 0, -2 );
		Size = UDim2.new( 1, -5, 0, 2 );
		BackgroundTransparency = ( self.Options.axes == "local" ) and 0 or 1;
	};

	RbxUtility.Create "TextButton" {
		Parent = GUIRoot.Container.AxesOption.Local;
		Name = "Button";
		Active = true;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 0 );
		Size = UDim2.new( 1, -10, 1, 0 );
		ZIndex = 2;
		Text = "";
		TextTransparency = 1;

		-- Change the axis type option when the button is clicked
		[RbxUtility.Create.E "MouseButton1Down"] = function ()
			self.Options.axes = "local";
			self:updateAxes();
			GUIRoot.Container.AxesOption.Global.SelectedIndicator.BackgroundTransparency = 1;
			GUIRoot.Container.AxesOption.Global.Background.Image = light_slanted_rectangle;
			GUIRoot.Container.AxesOption.Local.SelectedIndicator.BackgroundTransparency = 0;
			GUIRoot.Container.AxesOption.Local.Background.Image = dark_slanted_rectangle;
			GUIRoot.Container.AxesOption.Last.SelectedIndicator.BackgroundTransparency = 1;
			GUIRoot.Container.AxesOption.Last.Background.Image = light_slanted_rectangle;
		end;
	};

	RbxUtility.Create "ImageLabel" {
		Parent = GUIRoot.Container.AxesOption.Local;
		Name = "Background";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Image = ( self.Options.axes == "local" ) and dark_slanted_rectangle or light_slanted_rectangle;
		Size = UDim2.new( 1, 0, 1, 0 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.AxesOption.Local;
		Name = "Label";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "LOCAL";
		TextColor3 = Color3.new( 1, 1, 1 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.AxesOption;
		Name = "Last";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 175, 0, 0 );
		Size = UDim2.new( 0, 70, 0, 25 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.AxesOption.Last;
		Name = "SelectedIndicator";
		BackgroundColor3 = Color3.new( 1, 1, 1 );
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 6, 0, -2 );
		Size = UDim2.new( 1, -5, 0, 2 );
		BackgroundTransparency = ( self.Options.axes == "last" ) and 0 or 1;
	};

	RbxUtility.Create "TextButton" {
		Parent = GUIRoot.Container.AxesOption.Last;
		Name = "Button";
		Active = true;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 0 );
		Size = UDim2.new( 1, -10, 1, 0 );
		ZIndex = 2;
		Text = "";
		TextTransparency = 1;

		-- Change the axis type option when the button is clicked
		[RbxUtility.Create.E "MouseButton1Down"] = function ()
			self.Options.axes = "last";
			self:updateAxes();
			GUIRoot.Container.AxesOption.Global.SelectedIndicator.BackgroundTransparency = 1;
			GUIRoot.Container.AxesOption.Global.Background.Image = light_slanted_rectangle;
			GUIRoot.Container.AxesOption.Local.SelectedIndicator.BackgroundTransparency = 1;
			GUIRoot.Container.AxesOption.Local.Background.Image = light_slanted_rectangle;
			GUIRoot.Container.AxesOption.Last.SelectedIndicator.BackgroundTransparency = 0;
			GUIRoot.Container.AxesOption.Last.Background.Image = dark_slanted_rectangle;
		end;
	};

	RbxUtility.Create "ImageLabel" {
		Parent = GUIRoot.Container.AxesOption.Last;
		Name = "Background";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Image = ( self.Options.axes == "last" ) and dark_slanted_rectangle or light_slanted_rectangle;
		Size = UDim2.new( 1, 0, 1, 0 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.AxesOption.Last;
		Name = "Label";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "LAST";
		TextColor3 = Color3.new( 1, 1, 1 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.AxesOption;
		Name = "Label";
		BorderSizePixel = 0;
		BackgroundTransparency = 1;
		Size = UDim2.new( 0, 50, 0, 25 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.AxesOption.Label;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "Axes";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextWrapped = true;
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextStrokeTransparency = 0;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container;
		Name = "Title";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 0, 20 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.Title;
		Name = "ColorBar";
		BackgroundColor3 = Color3.new( 255 / 255, 170 / 255, 0 );
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, -3 );
		Size = UDim2.new( 1, -5, 0, 2 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Title;
		Name = "Label";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 10, 0, 1 );
		Size = UDim2.new( 1, -10, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "MOVE TOOL";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextXAlignment = Enum.TextXAlignment.Left;
		TextStrokeTransparency = 0;
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextWrapped = true;
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Title;
		Name = "F3XSignature";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 10, 0, 1 );
		Size = UDim2.new( 1, -10, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size14;
		Text = "F3X";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextXAlignment = Enum.TextXAlignment.Right;
		TextStrokeTransparency = 0.9;
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextWrapped = true;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container;
		Name = "IncrementOption";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 0, 0, 65 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.IncrementOption;
		Name = "Increment";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 70, 0, 0 );
		Size = UDim2.new( 0, 50, 0, 25 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.IncrementOption.Increment;
		Name = "SelectedIndicator";
		BorderSizePixel = 0;
		BackgroundColor3 = Color3.new( 1, 1, 1 );
		Size = UDim2.new( 1, -4, 0, 2 );
		Position = UDim2.new( 0, 5, 0, -2 );
	};

	RbxUtility.Create "TextBox" {
		Parent = GUIRoot.Container.IncrementOption.Increment;
		BorderSizePixel = 0;
		BackgroundTransparency = 1;
		Position = UDim2.new( 0, 5, 0, 0 );
		Size = UDim2.new( 1, -10, 1, 0 );
		ZIndex = 2;
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = tostring( self.Options.increment );
		TextColor3 = Color3.new( 1, 1, 1 );

		-- Change the increment option when the value of the textbox is updated
		[RbxUtility.Create.E "FocusLost"] = function ( enter_pressed )
			if enter_pressed then
				self.Options.increment = tonumber( GUIRoot.Container.IncrementOption.Increment.TextBox.Text ) or self.Options.increment;
				GUIRoot.Container.IncrementOption.Increment.TextBox.Text = tostring( self.Options.increment );
			end;
		end;
	};

	RbxUtility.Create "ImageLabel" {
		Parent = GUIRoot.Container.IncrementOption.Increment;
		Name = "Background";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Image = light_slanted_rectangle;
		Size = UDim2.new( 1, 0, 1, 0 );
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.IncrementOption;
		Name = "Label";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 0, 75, 0, 25 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.IncrementOption.Label;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "Increment";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextStrokeTransparency = 0;
		TextWrapped = true;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container;
		Name = "Info";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 100 );
		Size = UDim2.new( 1, -5, 0, 60 );
		Visible = false;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.Info;
		Name = "ColorBar";
		BorderSizePixel = 0;
		BackgroundColor3 = Color3.new( 1, 170 / 255, 0 );
		Size = UDim2.new( 1, 0, 0, 2 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Info;
		Name = "Label";
		BorderSizePixel = 0;
		BackgroundTransparency = 1;
		Position = UDim2.new( 0, 10, 0, 2 );
		Size = UDim2.new( 1, -10, 0, 20 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "SELECTION INFO";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextStrokeTransparency = 0;
		TextWrapped = true;
		TextXAlignment = Enum.TextXAlignment.Left;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.Info;
		Name = "Center";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 0, 0, 30 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Info.Center;
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 0, 75, 0, 25 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "Position";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextStrokeColor3 = Color3.new( 0, 0, 0);
		TextStrokeTransparency = 0;
		TextWrapped = true;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.Info.Center;
		Name = "X";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 70, 0, 0 );
		Size = UDim2.new( 0, 50, 0, 25 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Info.Center.X;
		Name = "TextLabel";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 0 );
		Size = UDim2.new( 1, -10, 1, 0 );
		ZIndex = 2;
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextWrapped = true;
	};

	RbxUtility.Create "ImageLabel" {
		Parent = GUIRoot.Container.Info.Center.X;
		Name = "Background";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Image = light_slanted_rectangle;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.Info.Center;
		Name = "Y";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 117, 0, 0 );
		Size = UDim2.new( 0, 50, 0, 25 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Info.Center.Y;
		Name = "TextLabel";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 0 );
		Size = UDim2.new( 1, -10, 1, 0 );
		ZIndex = 2;
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextWrapped = true;
	};

	RbxUtility.Create "ImageLabel" {
		Parent = GUIRoot.Container.Info.Center.Y;
		Name = "Background";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Image = light_slanted_rectangle;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.Info.Center;
		Name = "Z";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 164, 0, 0 );
		Size = UDim2.new( 0, 50, 0, 25 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Info.Center.Z;
		Name = "TextLabel";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 0 );
		Size = UDim2.new( 1, -10, 1, 0 );
		ZIndex = 2;
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size12;
		Text = "";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextWrapped = true;
	};

	RbxUtility.Create "ImageLabel" {
		Parent = GUIRoot.Container.Info.Center.Z;
		Name = "Background";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Size = UDim2.new( 1, 0, 1, 0 );
		Image = light_slanted_rectangle;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container;
		Name = "Changes";
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		Position = UDim2.new( 0, 5, 0, 165 );
		Size = UDim2.new( 1, -5, 0, 20 );
		Visible = false;
	};

	RbxUtility.Create "Frame" {
		Parent = GUIRoot.Container.Changes;
		Name = "ColorBar";
		BorderSizePixel = 0;
		BackgroundColor3 = Color3.new( 1, 170 / 255, 0 );
		Size = UDim2.new( 1, 0, 0, 2 );
	};

	RbxUtility.Create "TextLabel" {
		Parent = GUIRoot.Container.Changes;
		Name = "Text";
		BorderSizePixel = 0;
		BackgroundTransparency = 1;
		Position = UDim2.new( 0, 10, 0, 2 );
		Size = UDim2.new( 1, -10, 0, 20 );
		Font = Enum.Font.ArialBold;
		FontSize = Enum.FontSize.Size11;
		Text = "";
		TextColor3 = Color3.new( 1, 1, 1 );
		TextStrokeColor3 = Color3.new( 0, 0, 0 );
		TextStrokeTransparency = 0.5;
		TextWrapped = true;
		TextXAlignment = Enum.TextXAlignment.Right;
	};

end;

Tools.Move.hideGUI = function ( self )
	-- Hide any existent options GUI for the move tool

	if self.Temporary.OptionsGUI then
		self.Temporary.OptionsGUI:Destroy();
		self.Temporary.OptionsGUI = nil;
	end;

end;

Tools.Move.updateAxes = function ( self )
	-- Updates the axis type of the tool depending on the options

	if self.Temporary.AdorneeWatcher then
		self.Temporary.AdorneeWatcher:disconnect();
		self.Temporary.AdorneeWatcher = nil;
	end;

	if self.Temporary.LocalAxesChooser then
		self.Temporary.LocalAxesChooser:disconnect();
		self.Temporary.LocalAxesChooser = nil;
	end;

	self.Temporary.Handles.Adornee = nil;

	if self.Options.axes == "global" then
		if self.Temporary.BoundaryBox.Parent then
			self.Temporary.Handles.Adornee = self.Temporary.BoundaryBox;
		end;
	end;

	if self.Options.axes == "local" then

		-- If there is a last item in the selection, attach the handles to it
		if Selection.Last then
			self.Temporary.Handles.Adornee = Selection.Last;
		end;

		-- Move the handles over to whichever part is the mouse's current target
		self.Temporary.LocalAxesChooser = Mouse.Button2Up:connect( function ()
			if Selection:find( Mouse.Target ) then
				self.Temporary.Handles.Adornee = Mouse.Target;
			end;
		end );

	end;

	if self.Options.axes == "last" then

		-- If there is a last item in the selection, attach the handles to it
		if Selection.Last then
			self.Temporary.Handles.Adornee = Selection.Last;
		end;

	end;

	-- Make sure to hide the handles when their adornee is removed
	if self.Temporary.Handles.Adornee then
		local Adornee = self.Temporary.Handles.Adornee;
		self.Temporary.AdorneeWatcher = self.Temporary.Handles.Adornee.AncestryChanged:connect( function ( Object, NewParent )
	 		if NewParent == nil then
				self.Temporary.Handles.Adornee = nil;
			else
				self.Temporary.Handles.Adornee = Adornee;
			end;
		end );
	end;

	-- Reload the boundary box's parent so that the AdorneeWatcher connection can catch it
	self.Temporary.BoundaryBox.Parent = self.Temporary.BoundaryBox.Parent;

end;

Tools.Move.createBoundaryBox = function ( self )
	-- Returns an empty boundary box

	local BoundaryBox = Instance.new( "Part" );
	BoundaryBox.Name = "BTBoundaryBox";
	BoundaryBox.Anchored = true;
	BoundaryBox.Locked = true;
	BoundaryBox.CanCollide = false;
	BoundaryBox.Transparency = 1;

	Mouse.TargetFilter = BoundaryBox;

	return BoundaryBox;

end;

Tools.Move.updateBoundaryBox = function ( self, BoundaryBox, part_collection )
	-- Returns the boundary box

	-- Make sure `BoundaryBox` exists
	if not BoundaryBox then
		return false;
	end;

	-- Delete the box if `part_collection` is empty or we're dragging and return a new one
	if #part_collection == 0 or self.State.dragging then
		BoundaryBox.Parent = nil;
		return BoundaryBox;
	end;

	-- Get the size and position of `part_collection`
	local Size, Position = _getCollectionInfo( part_collection );

	-- Make `BoundaryBox` cover the part collection
	BoundaryBox.Parent = Services.Workspace.CurrentCamera;
	BoundaryBox.Size = Size;
	BoundaryBox.CFrame = Position;

	-- Return `BoundaryBox`
	return BoundaryBox;

end;

------------------------------------------
-- Resize tool
------------------------------------------

-- Create the tool
Tools.Resize = {};

-- Create structures that will be used within the tool
Tools.Resize.Temporary = {
	["Connections"] = {};
};

Tools.Resize.Options = {
	["increment"] = 1;
	["directions"] = "normal";
};

Tools.Resize.State = {
	["PreResize"] = {};
	["previous_distance"] = 0;
	["resizing"] = false;
};

Tools.Resize.Listeners = {};

-- Define the color of the tool
Tools.Resize.Color = BrickColor.new( "Cyan" );

-- Create the handle
Tools.Resize.Handle = RbxUtility.Create "Part" {
	Name = "Handle";
	Locked = true;
	BrickColor = Tools.Resize.Color;
	FormFactor = Enum.FormFactor.Custom;
	Size = Vector3.new( 0.8, 0.8, 0.8 );
	TopSurface = Enum.SurfaceType.Smooth;
	BottomSurface = Enum.SurfaceType.Smooth;
};
RbxUtility.Create "Decal" {
	Parent = Tools.Resize.Handle;
	Face = Enum.NormalId.Front;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Resize.Handle;
	Face = Enum.NormalId.Back;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Resize.Handle;
	Face = Enum.NormalId.Left;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Resize.Handle;
	Face = Enum.NormalId.Right;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Resize.Handle;
	Face = Enum.NormalId.Top;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Resize.Handle;
	Face = Enum.NormalId.Bottom;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};

-- Set the grip for the handle
Tools.Resize.Grip = CFrame.new( 0, 0, 0.4 );

Tools.Resize.Listeners.Equipped = function ()

	-- Change the color of selection boxes temporarily
	Tools.Resize.Temporary.PreviousSelectionBoxColor = SelectionBoxColor;
	SelectionBoxColor = Tools.Resize.Color;
	updateSelectionBoxColor();

	-- Reveal the GUI
	Tools.Resize:showGUI();

	-- Always have the handles on the most recent addition to the selection
	table.insert( Tools.Resize.Temporary.Connections, Selection.Changed:connect( function ()

		-- Clear out any previous adornee
		Tools.Resize:hideHandles();

		-- If there /is/ a last item in the selection, attach the handles to it
		if Selection.Last then
			Tools.Resize:showHandles( Selection.Last );
		end;

	end ) );

	-- Switch the adornee of the handles if the second mouse button is pressed
	table.insert( Tools.Resize.Temporary.Connections, Mouse.Button2Up:connect( function ()

		-- Make sure the platform doesn't think we're selecting
		override_selection = true;

		-- If the target is in the selection, make it the new adornee
		if Selection:find( Mouse.Target ) then
			Tools.Resize:showHandles( Mouse.Target );
		end;

	end ) );

	-- Finally, attach the handles to the last item added to the selection (if any)
	if Selection.Last then
		Tools.Resize:showHandles( Selection.Last );
	end;

end;

Tools.Resize.Listeners.Unequipped = function ()

	-- Hide the GUI
	Tools.Resize:hideGUI();

	-- Hide the handles
	Tools.Resize:hideHandles();

	-- Clear out any temporary connections
	for connection_index, Connection in pairs( Tools.Resize.Temporary.Connections ) do
		Connection:disconnect();
		Tools.Resize.Temporary.Connections[connection_index] = nil;
	end;

	-- Restore the original color of the selection boxes
	SelectionBoxColor = Tools.Resize.Temporary.PreviousSelectionBoxColor;
	updateSelectionBoxColor();

end;

Tools.Resize.showGUI = function ( self )

	-- Create the GUI if it doesn't exist
	if not self.Temporary.GUI then
		local GUIRoot = Instance.new( "ScreenGui", Player.PlayerGui );
		GUIRoot.Name = "BTResizeToolGUI";

		RbxUtility.Create "Frame" {
			Parent = GUIRoot;
			Name = "Container";
			Active = true;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 280 );
			Size = UDim2.new( 0, 245, 0, 90 );
			Draggable = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "DirectionsOption";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 30 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.DirectionsOption;
			Name = "Normal";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 70, 0, 0 );
			Size = UDim2.new( 0, 70, 0, 25 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.DirectionsOption.Normal;
			Name = "SelectedIndicator";
			BackgroundColor3 = Color3.new( 1, 1, 1 );
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 6, 0, -2 );
			Size = UDim2.new( 1, -5, 0, 2 );
			BackgroundTransparency = ( self.Options.directions == "normal" ) and 0 or 1;
		};

		RbxUtility.Create "TextButton" {
			Parent = GUIRoot.Container.DirectionsOption.Normal;
			Name = "Button";
			Active = true;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Text = "";
			TextTransparency = 1;

			-- Change the axis type option when the button is clicked
			[RbxUtility.Create.E "MouseButton1Down"] = function ()
				self.Options.directions = "normal";
				GUIRoot.Container.DirectionsOption.Normal.SelectedIndicator.BackgroundTransparency = 0;
				GUIRoot.Container.DirectionsOption.Normal.Background.Image = dark_slanted_rectangle;
				GUIRoot.Container.DirectionsOption.Both.SelectedIndicator.BackgroundTransparency = 1;
				GUIRoot.Container.DirectionsOption.Both.Background.Image = light_slanted_rectangle;
			end;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.DirectionsOption.Normal;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = ( self.Options.directions == "normal" ) and dark_slanted_rectangle or light_slanted_rectangle;
			Size = UDim2.new( 1, 0, 1, 0 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.DirectionsOption.Normal;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "NORMAL";
			TextColor3 = Color3.new( 1, 1, 1 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.DirectionsOption;
			Name = "Both";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 135, 0, 0 );
			Size = UDim2.new( 0, 70, 0, 25 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.DirectionsOption.Both;
			Name = "SelectedIndicator";
			BackgroundColor3 = Color3.new( 1, 1, 1 );
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 6, 0, -2 );
			Size = UDim2.new( 1, -5, 0, 2 );
			BackgroundTransparency = ( self.Options.directions == "both" ) and 0 or 1;
		};

		RbxUtility.Create "TextButton" {
			Parent = GUIRoot.Container.DirectionsOption.Both;
			Name = "Button";
			Active = true;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Text = "";
			TextTransparency = 1;

			-- Change the axis type option when the button is clicked
			[RbxUtility.Create.E "MouseButton1Down"] = function ()
				self.Options.directions = "both";
				GUIRoot.Container.DirectionsOption.Normal.SelectedIndicator.BackgroundTransparency = 1;
				GUIRoot.Container.DirectionsOption.Normal.Background.Image = light_slanted_rectangle;
				GUIRoot.Container.DirectionsOption.Both.SelectedIndicator.BackgroundTransparency = 0;
				GUIRoot.Container.DirectionsOption.Both.Background.Image = dark_slanted_rectangle;
			end;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.DirectionsOption.Both;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = ( self.Options.directions == "both" ) and dark_slanted_rectangle or light_slanted_rectangle;
			Size = UDim2.new( 1, 0, 1, 0 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.DirectionsOption.Both;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "BOTH";
			TextColor3 = Color3.new( 1, 1, 1 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.DirectionsOption;
			Name = "Label";
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Size = UDim2.new( 0, 75, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.DirectionsOption.Label;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "Directions";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "Title";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 0, 20 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Title;
			Name = "ColorBar";
			BackgroundColor3 = self.Color.Color;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, -3 );
			Size = UDim2.new( 1, -5, 0, 2 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Title;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 10, 0, 1 );
			Size = UDim2.new( 1, -10, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "RESIZE TOOL";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextXAlignment = Enum.TextXAlignment.Left;
			TextStrokeTransparency = 0;
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextWrapped = true;
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Title;
			Name = "F3XSignature";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 10, 0, 1 );
			Size = UDim2.new( 1, -10, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size14;
			Text = "F3X";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextXAlignment = Enum.TextXAlignment.Right;
			TextStrokeTransparency = 0.9;
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextWrapped = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "IncrementOption";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 65 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.IncrementOption;
			Name = "Increment";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 70, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.IncrementOption.Increment;
			Name = "SelectedIndicator";
			BorderSizePixel = 0;
			BackgroundColor3 = Color3.new( 1, 1, 1 );
			Size = UDim2.new( 1, -4, 0, 2 );
			Position = UDim2.new( 0, 5, 0, -2 );
		};

		RbxUtility.Create "TextBox" {
			Parent = GUIRoot.Container.IncrementOption.Increment;
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = tostring( self.Options.increment );
			TextColor3 = Color3.new( 1, 1, 1 );

			-- Change the increment option when the value of the textbox is updated
			[RbxUtility.Create.E "FocusLost"] = function ( enter_pressed )
				if enter_pressed then
					self.Options.increment = tonumber( GUIRoot.Container.IncrementOption.Increment.TextBox.Text ) or self.Options.increment;
					GUIRoot.Container.IncrementOption.Increment.TextBox.Text = tostring( self.Options.increment );
				end;
			end;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.IncrementOption.Increment;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = light_slanted_rectangle;
			Size = UDim2.new( 1, 0, 1, 0 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.IncrementOption;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 0, 75, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.IncrementOption.Label;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "Increment";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0;
			TextWrapped = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "Info";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 100 );
			Size = UDim2.new( 1, -5, 0, 60 );
			Visible = false;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info;
			Name = "ColorBar";
			BorderSizePixel = 0;
			BackgroundColor3 = self.Color.Color;
			Size = UDim2.new( 1, 0, 0, 2 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info;
			Name = "Label";
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Position = UDim2.new( 0, 10, 0, 2 );
			Size = UDim2.new( 1, -10, 0, 20 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "SELECTION INFO";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0;
			TextWrapped = true;
			TextXAlignment = Enum.TextXAlignment.Left;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info;
			Name = "SizeInfo";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 30 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.SizeInfo;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 0, 75, 0, 25 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "Size";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0);
			TextStrokeTransparency = 0;
			TextWrapped = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info.SizeInfo;
			Name = "X";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 70, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.SizeInfo.X;
			Name = "TextLabel";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.Info.SizeInfo.X;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Image = light_slanted_rectangle;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info.SizeInfo;
			Name = "Y";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 117, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.SizeInfo.Y;
			Name = "TextLabel";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.Info.SizeInfo.Y;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Image = light_slanted_rectangle;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info.SizeInfo;
			Name = "Z";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 164, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.SizeInfo.Z;
			Name = "TextLabel";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.Info.SizeInfo.Z;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Image = light_slanted_rectangle;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "Changes";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 165 );
			Size = UDim2.new( 1, -5, 0, 20 );
			Visible = false;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Changes;
			Name = "ColorBar";
			BorderSizePixel = 0;
			BackgroundColor3 = self.Color.Color;
			Size = UDim2.new( 1, 0, 0, 2 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Changes;
			Name = "Text";
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Position = UDim2.new( 0, 10, 0, 2 );
			Size = UDim2.new( 1, -10, 0, 20 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size11;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0.5;
			TextWrapped = true;
			TextXAlignment = Enum.TextXAlignment.Right;
		};

		-- Constantly update the GUI if it's visible
		coroutine.wrap( function ()
			while wait( 0.1 ) do
				if GUIRoot.Container.Visible then
					self:updateGUI();
				end;
			end;
		end )();

		self.Temporary.GUI = GUIRoot;
	end;

	-- Reveal the GUI
	self.Temporary.GUI.Container.Visible = true;

end;

Tools.Resize.updateGUI = function ( self )

	-- Make sure the GUI exists
	if not self.Temporary.GUI then
		return;
	end;

	local GUI = self.Temporary.GUI.Container;

	if #Selection.Items > 0 then

		-- Look for identical numbers in each axis
		local size_x, size_y, size_z =  nil, nil, nil;
		for item_index, Item in pairs( Selection.Items ) do

			-- Set the first values for the first item
			if item_index == 1 then
				size_x, size_y, size_z = _round( Item.Size.x, 2 ), _round( Item.Size.y, 2 ), _round( Item.Size.z, 2 );

			-- Otherwise, compare them and set them to `nil` if they're not identical
			else
				if size_x ~= _round( Item.Size.x, 2 ) then
					size_x = nil;
				end;
				if size_y ~= _round( Item.Size.y, 2 ) then
					size_y = nil;
				end;
				if size_z ~= _round( Item.Size.z, 2 ) then
					size_z = nil;
				end;
			end;

		end;

		-- Update the size info on the GUI
		GUI.Info.SizeInfo.X.TextLabel.Text = size_x and tostring( size_x ) or "*";
		GUI.Info.SizeInfo.Y.TextLabel.Text = size_y and tostring( size_y ) or "*";
		GUI.Info.SizeInfo.Z.TextLabel.Text = size_z and tostring( size_z ) or "*";

		GUI.Info.Visible = true;
	else
		GUI.Info.Visible = false;
	end;

	if self.State.length_resized then
		GUI.Changes.Text.Text = "resized " .. tostring( self.State.length_resized ) .. " studs";
		GUI.Changes.Position = GUI.Info.Visible and UDim2.new( 0, 5, 0, 165 ) or UDim2.new( 0, 5, 0, 100 );
		GUI.Changes.Visible = true;
	else
		GUI.Changes.Text.Text = "";
		GUI.Changes.Visible = false;
	end;

end;

Tools.Resize.hideGUI = function ( self )

	-- Hide the GUI if it exists
	if self.Temporary.GUI then
		self.Temporary.GUI.Container.Visible = false;
	end;

end;

Tools.Resize.showHandles = function ( self, Part )

	-- Create the handles if they don't exist yet
	if not self.Temporary.Handles then

		-- Create the object
		self.Temporary.Handles = RbxUtility.Create "Handles" {
			Name = "BTMovementHandles";
			Style = Enum.HandlesStyle.Resize;
			Color = self.Color;
			Parent = Player.PlayerGui;
		};

		-- Add functionality to the handles
		self.Temporary.Handles.MouseButton1Down:connect( function ()

			-- Prevent the platform from thinking we're selecting
			override_selection = true;
			self.State.resizing = true;

			-- Clear the change stats
			self.State.length_resized = 0;

			-- Do a few things to the selection before manipulating it
			for _, Item in pairs( Selection.Items ) do

				-- Keep a copy of the state of each item
				self.State.PreResize[Item] = Item:Clone();

				-- Make the item be able to be freely resized
				Item.FormFactor = Enum.FormFactor.Custom;

				-- Anchor each item
				Item.Anchored = true;

			end;

			-- Return stuff to normal once the mouse button is released
			self.Temporary.Connections.HandleReleaseListener = Mouse.Button1Up:connect( function ()

				-- Prevent the platform from thinking we're selecting
				override_selection = true;
				self.State.resizing = false;

				-- Stop this connection from firing again
				if self.Temporary.Connections.HandleReleaseListener then
					self.Temporary.Connections.HandleReleaseListener:disconnect();
					self.Temporary.Connections.HandleReleaseListener = nil;
				end;

				-- Restore properties that may have been changed temporarily
				-- from the pre-resize state copies
				for Item, PreviousItemState in pairs( self.State.PreResize ) do
					Item.Anchored = PreviousItemState.Anchored;
					self.State.PreResize[Item] = nil;
					Item:MakeJoints();
				end;

			end );

		end );

		self.Temporary.Handles.MouseDrag:connect( function ( face, drag_distance )
			
			-- Calculate which multiple of the increment to use based on the current drag distance's
			-- proximity to their nearest upper and lower multiples

			local difference = drag_distance % self.Options.increment;

			local lower_degree = drag_distance - difference;
			local upper_degree = drag_distance - difference + self.Options.increment;

			local lower_degree_proximity = math.abs( drag_distance - lower_degree );
			local upper_degree_proximity = math.abs( drag_distance - upper_degree );

			if lower_degree_proximity <= upper_degree_proximity then
				drag_distance = lower_degree;
			else
				drag_distance = upper_degree;
			end;

			local increase = drag_distance;

			-- Log the distance that the handle was dragged
			self.State.previous_distance = drag_distance;

			-- Note the length by which the selection will be enlarged
			if self.Options.directions == "both" then
				increase = drag_distance * 2;
			end;
			self.State.length_resized = increase;

			-- Go through the selection and make changes to it
			for _, Item in pairs( Selection.Items ) do

				-- Keep a copy of `Item` in case we need to revert anything
				local PreviousItemState = Item:Clone();

				-- Break any of `Item`'s joints so it can move freely
				Item:BreakJoints();

				-- Position and resize `Item` according to the options and the handle that was used

				if face == Enum.NormalId.Top then

					-- Calculate the appropriate increment to the size based on the shape of `Item`
					local SizeIncrease;
					if Item.Shape == Enum.PartType.Ball or Item.Shape == Enum.PartType.Cylinder then
						SizeIncrease = Vector3.new( increase, increase, increase );
					elseif Item.Shape == Enum.PartType.Block then
						SizeIncrease = Vector3.new( 0, increase, 0 );
					end;

					Item.Size = self.State.PreResize[Item].Size + SizeIncrease;
					if Item.Size == self.State.PreResize[Item].Size + SizeIncrease then
						Item.CFrame = ( self.Options.directions == "normal" and self.State.PreResize[Item].CFrame:toWorldSpace( CFrame.new( 0, increase / 2, 0 ) ) )
									  or ( self.Options.directions == "both" and self.State.PreResize[Item].CFrame );
					-- If the resizing was not possible, revert `Item`'s state
					else
						Item.Size = PreviousItemState.Size;
						Item.CFrame = PreviousItemState.CFrame;
					end;

				elseif face == Enum.NormalId.Bottom then

					-- Calculate the appropriate increment to the size based on the shape of `Item`
					local SizeIncrease;
					if Item.Shape == Enum.PartType.Ball or Item.Shape == Enum.PartType.Cylinder then
						SizeIncrease = Vector3.new( increase, increase, increase );
					elseif Item.Shape == Enum.PartType.Block then
						SizeIncrease = Vector3.new( 0, increase, 0 );
					end;

					Item.Size = self.State.PreResize[Item].Size + SizeIncrease;
					if Item.Size == self.State.PreResize[Item].Size + SizeIncrease then
						Item.CFrame = ( self.Options.directions == "normal" and self.State.PreResize[Item].CFrame:toWorldSpace( CFrame.new( 0, -increase / 2, 0 ) ) )
									  or ( self.Options.directions == "both" and self.State.PreResize[Item].CFrame );
					-- If the resizing was not possible, revert `Item`'s state
					else
						Item.Size = PreviousItemState.Size;
						Item.CFrame = PreviousItemState.CFrame;
					end;

				elseif face == Enum.NormalId.Front then

					-- Calculate the appropriate increment to the size based on the shape of `Item`
					local SizeIncrease;
					if Item.Shape == Enum.PartType.Ball or Item.Shape == Enum.PartType.Cylinder then
						SizeIncrease = Vector3.new( increase, increase, increase );
					elseif Item.Shape == Enum.PartType.Block then
						SizeIncrease = Vector3.new( 0, 0, increase );
					end;

					Item.Size = self.State.PreResize[Item].Size + SizeIncrease;
					if Item.Size == self.State.PreResize[Item].Size + SizeIncrease then
						Item.CFrame = ( self.Options.directions == "normal" and self.State.PreResize[Item].CFrame:toWorldSpace( CFrame.new( 0, 0, -increase / 2 ) ) )
									  or ( self.Options.directions == "both" and self.State.PreResize[Item].CFrame );
					-- If the resizing was not possible, revert `Item`'s state
					else
						Item.Size = PreviousItemState.Size;
						Item.CFrame = PreviousItemState.CFrame;
					end;

				elseif face == Enum.NormalId.Back then

					-- Calculate the appropriate increment to the size based on the shape of `Item`
					local SizeIncrease;
					if Item.Shape == Enum.PartType.Ball or Item.Shape == Enum.PartType.Cylinder then
						SizeIncrease = Vector3.new( increase, increase, increase );
					elseif Item.Shape == Enum.PartType.Block then
						SizeIncrease = Vector3.new( 0, 0, increase );
					end;

					Item.Size = self.State.PreResize[Item].Size + SizeIncrease;
					if Item.Size == self.State.PreResize[Item].Size + SizeIncrease then
						Item.CFrame = ( self.Options.directions == "normal" and self.State.PreResize[Item].CFrame:toWorldSpace( CFrame.new( 0, 0, increase / 2 ) ) )
									  or ( self.Options.directions == "both" and self.State.PreResize[Item].CFrame );
					-- If the resizing was not possible, revert `Item`'s state
					else
						Item.Size = PreviousItemState.Size;
						Item.CFrame = PreviousItemState.CFrame;
					end;

				elseif face == Enum.NormalId.Left then

					-- Calculate the appropriate increment to the size based on the shape of `Item`
					local SizeIncrease;
					if Item.Shape == Enum.PartType.Ball or Item.Shape == Enum.PartType.Cylinder then
						SizeIncrease = Vector3.new( increase, increase, increase );
					elseif Item.Shape == Enum.PartType.Block then
						SizeIncrease = Vector3.new( increase, 0, 0 );
					end;

					Item.Size = self.State.PreResize[Item].Size + SizeIncrease;
					if Item.Size == self.State.PreResize[Item].Size + SizeIncrease then
						Item.CFrame = ( self.Options.directions == "normal" and self.State.PreResize[Item].CFrame:toWorldSpace( CFrame.new( -increase / 2, 0, 0 ) ) )
									  or ( self.Options.directions == "both" and self.State.PreResize[Item].CFrame );
					-- If the resizing was not possible, revert `Item`'s state
					else
						Item.Size = PreviousItemState.Size;
						Item.CFrame = PreviousItemState.CFrame;
					end;

				elseif face == Enum.NormalId.Right then

					-- Calculate the appropriate increment to the size based on the shape of `Item`
					local SizeIncrease;
					if Item.Shape == Enum.PartType.Ball or Item.Shape == Enum.PartType.Cylinder then
						SizeIncrease = Vector3.new( increase, increase, increase );
					elseif Item.Shape == Enum.PartType.Block then
						SizeIncrease = Vector3.new( increase, 0, 0 );
					end;

					Item.Size = self.State.PreResize[Item].Size + SizeIncrease;
					if Item.Size == self.State.PreResize[Item].Size + SizeIncrease then
						Item.CFrame = ( self.Options.directions == "normal" and self.State.PreResize[Item].CFrame:toWorldSpace( CFrame.new( increase / 2, 0, 0 ) ) )
									  or ( self.Options.directions == "both" and self.State.PreResize[Item].CFrame );
					-- If the resizing was not possible, revert `Item`'s state
					else
						Item.Size = PreviousItemState.Size;
						Item.CFrame = PreviousItemState.CFrame;
					end;
				end;

				-- Make joints with surrounding parts again once the resizing is done
				Item:MakeJoints();

			end;

		end );

	end;

	-- Stop listening for the existence of the previous adornee (if any)
	if self.Temporary.Connections.AdorneeExistenceListener then
		self.Temporary.Connections.AdorneeExistenceListener:disconnect();
		self.Temporary.Connections.AdorneeExistenceListener = nil;
	end;

	-- Attach the handles to `Part`
	self.Temporary.Handles.Adornee = Part;

	-- Make sure to hide the handles if `Part` suddenly stops existing
	self.Temporary.Connections.AdorneeExistenceListener = Part.AncestryChanged:connect( function ( Object, NewParent )

		-- Make sure this change in parent applies directly to `Part`
		if Object ~= Part then
			return;
		end;

		-- Show the handles according to the existence of the part
		if NewParent == nil then
			self:hideHandles();
		else
			self:showHandles( Part );
		end;

	end );

end;

Tools.Resize.hideHandles = function ( self )

	-- Hide the handles if they exist
	if self.Temporary.Handles then
		self.Temporary.Handles.Adornee = nil;
	end;

end;

------------------------------------------
-- Rotate tool
------------------------------------------

-- Create the tool
Tools.Rotate = {};

-- Create structures to hold data that the tool needs
Tools.Rotate.Temporary = {
	["Connections"] = {};
};

Tools.Rotate.Options = {
	["increment"] = 15;
	["pivot"] = "center"
};

Tools.Rotate.State = {
	["PreRotation"] = {};
	["rotating"] = false;
	["previous_distance"] = 0;
	["degrees_rotated"] = 0;
	["rotation_size"] = 0;
};

Tools.Rotate.Listeners = {};

-- Define the color of the tool
Tools.Rotate.Color = BrickColor.new( "Bright green" );

-- Create the handle
Tools.Rotate.Handle = RbxUtility.Create "Part" {
	Name = "Handle";
	Locked = true;
	BrickColor = Tools.Rotate.Color;
	FormFactor = Enum.FormFactor.Custom;
	Size = Vector3.new( 0.8, 0.8, 0.8 );
	TopSurface = Enum.SurfaceType.Smooth;
	BottomSurface = Enum.SurfaceType.Smooth;
};
RbxUtility.Create "Decal" {
	Parent = Tools.Rotate.Handle;
	Face = Enum.NormalId.Front;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Rotate.Handle;
	Face = Enum.NormalId.Back;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Rotate.Handle;
	Face = Enum.NormalId.Left;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Rotate.Handle;
	Face = Enum.NormalId.Right;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Rotate.Handle;
	Face = Enum.NormalId.Top;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};
RbxUtility.Create "Decal" {
	Parent = Tools.Rotate.Handle;
	Face = Enum.NormalId.Bottom;
	Texture = "http://www.roblox.com/asset/?id=129748355";
};

-- Set the grip for the handle
Tools.Rotate.Grip = CFrame.new( 0, 0, 0.4 );

-- Start adding functionality to the tool

Tools.Rotate.Listeners.Equipped = function ()

	-- Change the color of selection boxes temporarily
	Tools.Rotate.Temporary.PreviousSelectionBoxColor = SelectionBoxColor;
	SelectionBoxColor = Tools.Rotate.Color;
	updateSelectionBoxColor();

	-- Reveal the GUI
	Tools.Rotate:showGUI();

	-- Create the boundingbox if it doesn't already exist
	if not Tools.Rotate.Temporary.BoundingBox then
		Tools.Rotate.Temporary.BoundingBox = RbxUtility.Create "Part" {
			Name = "BTBoundingBox";
			CanCollide = false;
			Transparency = 1;
			Anchored = true;
		};
	end;
	Mouse.TargetFilter = Tools.Rotate.Temporary.BoundingBox;

	-- Update the pivot option
	Tools.Rotate:changePivot( "center" );

	-- Oh, and update the boundingbox and the GUI regularly
	coroutine.wrap( function ()
		local updater_on = true;

		-- Provide a function to stop the loop
		Tools.Rotate.Temporary.Updater = function ()
			updater_on = false;
		end;

		while wait( 0.1 ) and updater_on do

			-- Make sure the tool's equipped
			if Options.Tool == Tools.Rotate then

				-- Update the GUI if it's visible
				if Tools.Rotate.Temporary.GUI and Tools.Rotate.Temporary.GUI.Container.Visible then
					Tools.Rotate:updateGUI();
				end;

				-- Update the boundingbox if it's visible
				if Tools.Rotate.Options.pivot == "center" then
					Tools.Rotate:updateBoundingBox();
				end;

			end;

		end;

	end )();

end;

Tools.Rotate.Listeners.Unequipped = function ()

	-- Stop the update loop
	Tools.Rotate.Temporary.Updater();
	Tools.Rotate.Temporary.Updater = nil;

	-- Hide the GUI
	Tools.Rotate:hideGUI();

	-- Hide the handles
	Tools.Rotate:hideHandles();

	-- Hide the boundingbox
	Tools.Rotate.Temporary.BoundingBox.Parent = nil;

	-- Clear out any temporary connections
	for connection_index, Connection in pairs( Tools.Rotate.Temporary.Connections ) do
		Connection:disconnect();
		Tools.Rotate.Temporary.Connections[connection_index] = nil;
	end;

	-- Restore the original color of the selection boxes
	SelectionBoxColor = Tools.Rotate.Temporary.PreviousSelectionBoxColor;
	updateSelectionBoxColor();

end;

Tools.Rotate.showGUI = function ( self )

	-- Create the GUI if it doesn't exist
	if not self.Temporary.GUI then
		local GUIRoot = Instance.new( "ScreenGui", Player.PlayerGui );
		GUIRoot.Name = "BTRotateToolGUI";

		RbxUtility.Create "Frame" {
			Parent = GUIRoot;
			Name = "Container";
			Active = true;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 280 );
			Size = UDim2.new( 0, 245, 0, 90 );
			Draggable = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "PivotOption";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 30 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.PivotOption;
			Name = "Center";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 50, 0, 0 );
			Size = UDim2.new( 0, 70, 0, 25 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.PivotOption.Center;
			Name = "SelectedIndicator";
			BackgroundColor3 = Color3.new( 1, 1, 1 );
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 6, 0, -2 );
			Size = UDim2.new( 1, -5, 0, 2 );
			BackgroundTransparency = ( self.Options.pivot == "center" ) and 0 or 1;
		};

		RbxUtility.Create "TextButton" {
			Parent = GUIRoot.Container.PivotOption.Center;
			Name = "Button";
			Active = true;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Text = "";
			TextTransparency = 1;

			-- Change the pivot type option when the button is clicked
			[RbxUtility.Create.E "MouseButton1Down"] = function ()
				self:changePivot( "center" );
			end;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.PivotOption.Center;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = ( self.Options.pivot == "center" ) and dark_slanted_rectangle or light_slanted_rectangle;
			Size = UDim2.new( 1, 0, 1, 0 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.PivotOption.Center;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "CENTER";
			TextColor3 = Color3.new( 1, 1, 1 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.PivotOption;
			Name = "Local";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 115, 0, 0 );
			Size = UDim2.new( 0, 70, 0, 25 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.PivotOption.Local;
			Name = "SelectedIndicator";
			BackgroundColor3 = Color3.new( 1, 1, 1 );
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 6, 0, -2 );
			Size = UDim2.new( 1, -5, 0, 2 );
			BackgroundTransparency = ( self.Options.pivot == "local" ) and 0 or 1;
		};

		RbxUtility.Create "TextButton" {
			Parent = GUIRoot.Container.PivotOption.Local;
			Name = "Button";
			Active = true;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Text = "";
			TextTransparency = 1;

			-- Change the pivot type option when the button is clicked
			[RbxUtility.Create.E "MouseButton1Down"] = function ()
				self:changePivot( "local" );
			end;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.PivotOption.Local;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = ( self.Options.pivot == "local" ) and dark_slanted_rectangle or light_slanted_rectangle;
			Size = UDim2.new( 1, 0, 1, 0 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.PivotOption.Local;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "LOCAL";
			TextColor3 = Color3.new( 1, 1, 1 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.PivotOption;
			Name = "Last";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 180, 0, 0 );
			Size = UDim2.new( 0, 70, 0, 25 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.PivotOption.Last;
			Name = "SelectedIndicator";
			BackgroundColor3 = Color3.new( 1, 1, 1 );
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 6, 0, -2 );
			Size = UDim2.new( 1, -5, 0, 2 );
			BackgroundTransparency = ( self.Options.pivot == "last" ) and 0 or 1;
		};

		RbxUtility.Create "TextButton" {
			Parent = GUIRoot.Container.PivotOption.Last;
			Name = "Button";
			Active = true;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Text = "";
			TextTransparency = 1;

			-- Change the pivot type option when the button is clicked
			[RbxUtility.Create.E "MouseButton1Down"] = function ()
				self:changePivot( "last" );
			end;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.PivotOption.Last;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = ( self.Options.pivot == "last" ) and dark_slanted_rectangle or light_slanted_rectangle;
			Size = UDim2.new( 1, 0, 1, 0 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.PivotOption.Last;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "LAST";
			TextColor3 = Color3.new( 1, 1, 1 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.PivotOption;
			Name = "Label";
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.PivotOption.Label;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "Pivot";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "Title";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 0, 20 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Title;
			Name = "ColorBar";
			BackgroundColor3 = self.Color.Color;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, -3 );
			Size = UDim2.new( 1, -5, 0, 2 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Title;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 10, 0, 1 );
			Size = UDim2.new( 1, -10, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "ROTATE TOOL";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextXAlignment = Enum.TextXAlignment.Left;
			TextStrokeTransparency = 0;
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextWrapped = true;
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Title;
			Name = "F3XSignature";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 10, 0, 1 );
			Size = UDim2.new( 1, -10, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size14;
			Text = "F3X";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextXAlignment = Enum.TextXAlignment.Right;
			TextStrokeTransparency = 0.9;
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextWrapped = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "IncrementOption";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 65 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.IncrementOption;
			Name = "Increment";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 70, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.IncrementOption.Increment;
			Name = "SelectedIndicator";
			BorderSizePixel = 0;
			BackgroundColor3 = Color3.new( 1, 1, 1 );
			Size = UDim2.new( 1, -4, 0, 2 );
			Position = UDim2.new( 0, 5, 0, -2 );
		};

		RbxUtility.Create "TextBox" {
			Parent = GUIRoot.Container.IncrementOption.Increment;
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = tostring( self.Options.increment );
			TextColor3 = Color3.new( 1, 1, 1 );

			-- Change the increment option when the value of the textbox is updated
			[RbxUtility.Create.E "FocusLost"] = function ( enter_pressed )
				if enter_pressed then
					self.Options.increment = tonumber( GUIRoot.Container.IncrementOption.Increment.TextBox.Text ) or self.Options.increment;
					GUIRoot.Container.IncrementOption.Increment.TextBox.Text = tostring( self.Options.increment );
				end;
			end;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.IncrementOption.Increment;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Image = light_slanted_rectangle;
			Size = UDim2.new( 1, 0, 1, 0 );
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.IncrementOption;
			Name = "Label";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 0, 75, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.IncrementOption.Label;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "Increment";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0;
			TextWrapped = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "Info";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 100 );
			Size = UDim2.new( 1, -5, 0, 60 );
			Visible = false;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info;
			Name = "ColorBar";
			BorderSizePixel = 0;
			BackgroundColor3 = self.Color.Color;
			Size = UDim2.new( 1, 0, 0, 2 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info;
			Name = "Label";
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Position = UDim2.new( 0, 10, 0, 2 );
			Size = UDim2.new( 1, -10, 0, 20 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "SELECTION INFO";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0;
			TextWrapped = true;
			TextXAlignment = Enum.TextXAlignment.Left;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info;
			Name = "RotationInfo";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 0, 0, 30 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.RotationInfo;
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 0, 75, 0, 25 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "Rotation";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0);
			TextStrokeTransparency = 0;
			TextWrapped = true;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info.RotationInfo;
			Name = "X";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 70, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.RotationInfo.X;
			Name = "TextLabel";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.Info.RotationInfo.X;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Image = light_slanted_rectangle;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info.RotationInfo;
			Name = "Y";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 117, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.RotationInfo.Y;
			Name = "TextLabel";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.Info.RotationInfo.Y;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Image = light_slanted_rectangle;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Info.RotationInfo;
			Name = "Z";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 164, 0, 0 );
			Size = UDim2.new( 0, 50, 0, 25 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Info.RotationInfo.Z;
			Name = "TextLabel";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 0 );
			Size = UDim2.new( 1, -10, 1, 0 );
			ZIndex = 2;
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size12;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextWrapped = true;
		};

		RbxUtility.Create "ImageLabel" {
			Parent = GUIRoot.Container.Info.RotationInfo.Z;
			Name = "Background";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Size = UDim2.new( 1, 0, 1, 0 );
			Image = light_slanted_rectangle;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container;
			Name = "Changes";
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new( 0, 5, 0, 165 );
			Size = UDim2.new( 1, -5, 0, 20 );
			Visible = false;
		};

		RbxUtility.Create "Frame" {
			Parent = GUIRoot.Container.Changes;
			Name = "ColorBar";
			BorderSizePixel = 0;
			BackgroundColor3 = self.Color.Color;
			Size = UDim2.new( 1, 0, 0, 2 );
		};

		RbxUtility.Create "TextLabel" {
			Parent = GUIRoot.Container.Changes;
			Name = "Text";
			BorderSizePixel = 0;
			BackgroundTransparency = 1;
			Position = UDim2.new( 0, 10, 0, 2 );
			Size = UDim2.new( 1, -10, 0, 20 );
			Font = Enum.Font.ArialBold;
			FontSize = Enum.FontSize.Size11;
			Text = "";
			TextColor3 = Color3.new( 1, 1, 1 );
			TextStrokeColor3 = Color3.new( 0, 0, 0 );
			TextStrokeTransparency = 0.5;
			TextWrapped = true;
			TextXAlignment = Enum.TextXAlignment.Right;
		};

		self.Temporary.GUI = GUIRoot;
	end;

	-- Reveal the GUI
	self.Temporary.GUI.Container.Visible = true;

end;

Tools.Rotate.updateGUI = function ( self )

	-- Make sure the GUI exists
	if not self.Temporary.GUI then
		return;
	end;

	local GUI = self.Temporary.GUI.Container;

	if #Selection.Items > 0 then

		-- Look for identical numbers in each axis
		local rot_x, rot_y, rot_z = nil, nil, nil;
		for item_index, Item in pairs( Selection.Items ) do

			local item_rot_x, item_rot_y, item_rot_z = Item.CFrame:toEulerAnglesXYZ();

			-- Set the first values for the first item
			if item_index == 1 then
				rot_x, rot_y, rot_z = _round( math.deg( item_rot_x ), 2 ), _round( math.deg( item_rot_y ), 2 ), _round( math.deg( item_rot_z ), 2 );

			-- Otherwise, compare them and set them to `nil` if they're not identical
			else
				if rot_x ~= _round( math.deg( item_rot_x ), 2 ) then
					rot_x = nil;
				end;
				if rot_y ~= _round( math.deg( item_rot_y ), 2 ) then
					rot_y = nil;
				end;
				if rot_z ~= _round( math.deg( item_rot_z ), 2 ) then
					rot_z = nil;
				end;
			end;

		end;

		-- Update the size info on the GUI
		GUI.Info.RotationInfo.X.TextLabel.Text = rot_x and tostring( rot_x ) or "*";
		GUI.Info.RotationInfo.Y.TextLabel.Text = rot_y and tostring( rot_y ) or "*";
		GUI.Info.RotationInfo.Z.TextLabel.Text = rot_z and tostring( rot_z ) or "*";

		GUI.Info.Visible = true;
	else
		GUI.Info.Visible = false;
	end;

	if self.State.degrees_rotated then
		GUI.Changes.Text.Text = "rotated " .. tostring( self.State.degrees_rotated ) .. " degrees";
		GUI.Changes.Position = GUI.Info.Visible and UDim2.new( 0, 5, 0, 165 ) or UDim2.new( 0, 5, 0, 100 );
		GUI.Changes.Visible = true;
	else
		GUI.Changes.Text.Text = "";
		GUI.Changes.Visible = false;
	end;

end;

Tools.Rotate.hideGUI = function ( self )

	-- Hide the GUI if it exists
	if self.Temporary.GUI then
		self.Temporary.GUI.Container.Visible = false;
	end;

end;

Tools.Rotate.updateBoundingBox = function ( self )

	if #Selection.Items > 0 then
		local SelectionSize, SelectionPosition = _getCollectionInfo( Selection.Items );
		self.Temporary.BoundingBox.Parent = Services.Workspace.CurrentCamera;
		self.Temporary.BoundingBox.Size = SelectionSize;
		self.Temporary.BoundingBox.CFrame = SelectionPosition;
		self:showHandles( self.Temporary.BoundingBox );
	
	else
		self.Temporary.BoundingBox.Parent = nil;
		self:hideHandles();
	end;

end;

Tools.Rotate.changePivot = function ( self, new_pivot )

	-- Have a quick reference to the GUI (if any)
	local PivotOptionGUI = self.Temporary.GUI and self.Temporary.GUI.Container.PivotOption or nil;

	-- Disconnect any handle-related listeners that are specific to a certain pivot option

	if self.Temporary.Connections.HandleFocusChangeListener then
		self.Temporary.Connections.HandleFocusChangeListener:disconnect();
		self.Temporary.Connections.HandleFocusChangeListener = nil;
	end;

	if self.Temporary.Connections.HandleSelectionChangeListener then
		self.Temporary.Connections.HandleSelectionChangeListener:disconnect();
		self.Temporary.Connections.HandleSelectionChangeListener = nil;
	end;

	if new_pivot == "center" then

		-- Update the options
		self.Options.pivot = "center";

		-- Make the boundingbox visible
		self.Temporary.BoundingBox.Parent = Services.Workspace.CurrentCamera;

		-- Focus the handles on the boundingbox
		self:showHandles( self.Temporary.BoundingBox );

		-- Update the GUI's option panel
		if self.Temporary.GUI then
			PivotOptionGUI.Center.SelectedIndicator.BackgroundTransparency = 0;
			PivotOptionGUI.Center.Background.Image = dark_slanted_rectangle;
			PivotOptionGUI.Local.SelectedIndicator.BackgroundTransparency = 1;
			PivotOptionGUI.Local.Background.Image = light_slanted_rectangle;
			PivotOptionGUI.Last.SelectedIndicator.BackgroundTransparency = 1;
			PivotOptionGUI.Last.Background.Image = light_slanted_rectangle;
		end;

	end;

	if new_pivot == "local" then

		-- Update the options
		self.Options.pivot = "local";

		-- Hide the boundingbox
		self.Temporary.BoundingBox.Parent = nil;

		-- Always have the handles on the most recent addition to the selection
		self.Temporary.Connections.HandleSelectionChangeListener = Selection.Changed:connect( function ()

			-- Clear out any previous adornee
			self:hideHandles();

			-- If there /is/ a last item in the selection, attach the handles to it
			if Selection.Last then
				self:showHandles( Selection.Last );
			end;

		end );

		-- Switch the adornee of the handles if the second mouse button is pressed
		self.Temporary.Connections.HandleFocusChangeListener = Mouse.Button2Up:connect( function ()

			-- Make sure the platform doesn't think we're selecting
			override_selection = true;

			-- If the target is in the selection, make it the new adornee
			if Selection:find( Mouse.Target ) then
				Selection.Last = Mouse.Target;
				self:showHandles( Mouse.Target );
			end;

		end );

		-- Finally, attach the handles to the last item added to the selection (if any)
		if Selection.Last then
			self:showHandles( Selection.Last );
		end;

		-- Update the GUI's option panel
		if self.Temporary.GUI then
			PivotOptionGUI.Center.SelectedIndicator.BackgroundTransparency = 1;
			PivotOptionGUI.Center.Background.Image = light_slanted_rectangle;
			PivotOptionGUI.Local.SelectedIndicator.BackgroundTransparency = 0;
			PivotOptionGUI.Local.Background.Image = dark_slanted_rectangle;
			PivotOptionGUI.Last.SelectedIndicator.BackgroundTransparency = 1;
			PivotOptionGUI.Last.Background.Image = light_slanted_rectangle;
		end;

	end;

	if new_pivot == "last" then

		-- Update the options
		self.Options.pivot = "last";

		-- Hide the boundingbox
		self.Temporary.BoundingBox.Parent = nil;

		-- Always have the handles on the most recent addition to the selection
		self.Temporary.Connections.HandleSelectionChangeListener = Selection.Changed:connect( function ()

			-- Clear out any previous adornee
			self:hideHandles();

			-- If there /is/ a last item in the selection, attach the handles to it
			if Selection.Last then
				self:showHandles( Selection.Last );
			end;

		end );

		-- Switch the adornee of the handles if the second mouse button is pressed
		self.Temporary.Connections.HandleFocusChangeListener = Mouse.Button2Up:connect( function ()

			-- Make sure the platform doesn't think we're selecting
			override_selection = true;

			-- If the target is in the selection, make it the new adornee
			if Selection:find( Mouse.Target ) then
				Selection.Last = Mouse.Target;
				self:showHandles( Mouse.Target );
			end;

		end );

		-- Finally, attach the handles to the last item added to the selection (if any)
		if Selection.Last then
			self:showHandles( Selection.Last );
		end;

		-- Update the GUI's option panel
		if self.Temporary.GUI then
			PivotOptionGUI.Center.SelectedIndicator.BackgroundTransparency = 1;
			PivotOptionGUI.Center.Background.Image = light_slanted_rectangle;
			PivotOptionGUI.Local.SelectedIndicator.BackgroundTransparency = 1;
			PivotOptionGUI.Local.Background.Image = light_slanted_rectangle;
			PivotOptionGUI.Last.SelectedIndicator.BackgroundTransparency = 0;
			PivotOptionGUI.Last.Background.Image = dark_slanted_rectangle;
		end;

	end;

end;


Tools.Rotate.showHandles = function ( self, Part )

	-- Create the handles if they don't exist yet
	if not self.Temporary.Handles then

		-- Create the object
		self.Temporary.Handles = RbxUtility.Create "ArcHandles" {
			Name = "BTRotationHandles";
			Color = self.Color;
			Parent = Player.PlayerGui;
		};

		-- Add functionality to the handles

		self.Temporary.Handles.MouseButton1Down:connect( function ()

			-- Prevent the platform from thinking we're selecting
			override_selection = true;
			self.State.rotating = true;

			-- Clear the change stats
			self.State.degrees_rotated = 0;
			self.State.rotation_size = 0;

			-- Do a few things to the selection before manipulating it
			for _, Item in pairs( Selection.Items ) do

				-- Keep a copy of the state of each item
				self.State.PreRotation[Item] = Item:Clone();

				-- Anchor each item
				Item.Anchored = true;

			end;

			-- Also keep the position of the original selection
			local PreRotationSize, PreRotationPosition = _getCollectionInfo( self.State.PreRotation );
			self.State.PreRotationPosition = PreRotationPosition;

			-- Return stuff to normal once the mouse button is released
			self.Temporary.Connections.HandleReleaseListener = Mouse.Button1Up:connect( function ()

				-- Prevent the platform from thinking we're selecting
				override_selection = true;
				self.State.rotating = false;

				-- Stop this connection from firing again
				if self.Temporary.Connections.HandleReleaseListener then
					self.Temporary.Connections.HandleReleaseListener:disconnect();
					self.Temporary.Connections.HandleReleaseListener = nil;
				end;

				-- Restore properties that may have been changed temporarily
				-- from the pre-rotation state copies
				for Item, PreviousItemState in pairs( self.State.PreRotation ) do
					Item.Anchored = PreviousItemState.Anchored;
					self.State.PreRotation[Item] = nil;
					Item:MakeJoints();
				end;

			end );

		end );

		self.Temporary.Handles.MouseDrag:connect( function ( axis, drag_distance )
			
			-- Round down and convert the drag distance to degrees to make it easier to work with
			local drag_distance = math.floor( math.deg( drag_distance ) );

			-- Calculate which multiple of the increment to use based on the current angle's
			-- proximity to their nearest upper and lower multiples

			local difference = drag_distance % self.Options.increment;

			local lower_degree = drag_distance - difference;
			local upper_degree = drag_distance - difference + self.Options.increment;

			local lower_degree_proximity = math.abs( drag_distance - lower_degree );
			local upper_degree_proximity = math.abs( drag_distance - upper_degree );

			if lower_degree_proximity <= upper_degree_proximity then
				drag_distance = lower_degree;
			else
				drag_distance = upper_degree;
			end;

			local increase = self.Options.increment * math.floor( drag_distance / self.Options.increment );

			self.State.degrees_rotated = drag_distance;

			-- Go through the selection and make changes to it
			for _, Item in pairs( Selection.Items ) do

				-- Keep a copy of `Item` in case we need to revert anything
				local PreviousItemState = Item:Clone();

				-- Break any of `Item`'s joints so it can move freely
				Item:BreakJoints();

				-- Rotate `Item` according to the options and the handle that was used
				if axis == Enum.Axis.Y then
					if self.Options.pivot == "center" then
						Item.CFrame = self.State.PreRotationPosition:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( 0, math.rad( increase ), 0 ) ):toWorldSpace( self.State.PreRotation[Item].CFrame:toObjectSpace( self.State.PreRotationPosition ):inverse() );
					elseif self.Options.pivot == "local" then
						Item.CFrame = self.State.PreRotation[Item].CFrame:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( 0, math.rad( increase ), 0 ) );
					elseif self.Options.pivot == "last" then
						Item.CFrame = self.State.PreRotation[Selection.Last].CFrame:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( 0, math.rad( increase ), 0 ) ):toWorldSpace( self.State.PreRotation[Item].CFrame:toObjectSpace( self.State.PreRotation[Selection.Last].CFrame ):inverse() );
					end;
				elseif axis == Enum.Axis.X then
					if self.Options.pivot == "center" then
						Item.CFrame = self.State.PreRotationPosition:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( math.rad( increase ), 0, 0 ) ):toWorldSpace( self.State.PreRotation[Item].CFrame:toObjectSpace( self.State.PreRotationPosition ):inverse() );
					elseif self.Options.pivot == "local" then
						Item.CFrame = self.State.PreRotation[Item].CFrame:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( math.rad( increase ), 0, 0 ) );
					elseif self.Options.pivot == "last" then
						Item.CFrame = self.State.PreRotation[Selection.Last].CFrame:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( math.rad( increase ), 0, 0 ) ):toWorldSpace( self.State.PreRotation[Item].CFrame:toObjectSpace( self.State.PreRotation[Selection.Last].CFrame ):inverse() );
					end;
				elseif axis == Enum.Axis.Z then
					if self.Options.pivot == "center" then
						Item.CFrame = self.State.PreRotationPosition:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( 0, 0, math.rad( increase ) ) ):toWorldSpace( self.State.PreRotation[Item].CFrame:toObjectSpace( self.State.PreRotationPosition ):inverse() );
					elseif self.Options.pivot == "local" then
						Item.CFrame = self.State.PreRotation[Item].CFrame:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( 0, 0, math.rad( increase ) ) );
					elseif self.Options.pivot == "last" then
						Item.CFrame = self.State.PreRotation[Selection.Last].CFrame:toWorldSpace( CFrame.new( 0, 0, 0 ) * CFrame.Angles( 0, 0, math.rad( increase ) ) ):toWorldSpace( self.State.PreRotation[Item].CFrame:toObjectSpace( self.State.PreRotation[Selection.Last].CFrame ):inverse() );
					end;
				end;

				-- Make joints with surrounding parts again once the resizing is done
				Item:MakeJoints();

			end;

		end );

	end;

	-- Stop listening for the existence of the previous adornee (if any)
	if self.Temporary.Connections.AdorneeExistenceListener then
		self.Temporary.Connections.AdorneeExistenceListener:disconnect();
		self.Temporary.Connections.AdorneeExistenceListener = nil;
	end;

	-- Attach the handles to `Part`
	self.Temporary.Handles.Adornee = Part;

	-- Make sure to hide the handles if `Part` suddenly stops existing
	self.Temporary.Connections.AdorneeExistenceListener = Part.AncestryChanged:connect( function ( Object, NewParent )

		-- Make sure this change in parent applies directly to `Part`
		if Object ~= Part then
			return;
		end;

		-- Show the handles according to the existence of the part
		if NewParent == nil then
			self:hideHandles();
		else
			self:showHandles( Part );
		end;

	end );

end;

Tools.Rotate.hideHandles = function ( self )

	-- Hide the handles if they exist
	if self.Temporary.Handles then
		self.Temporary.Handles.Adornee = nil;
	end;

end;

------------------------------------------
-- Attach listeners
------------------------------------------

Tool.Equipped:connect( function ( CurrentMouse )

	Mouse = CurrentMouse;

	Options.TargetBox = Instance.new( "SelectionBox", Player.PlayerGui );
	Options.TargetBox.Name = "BTTargetBox";
	Options.TargetBox.Color = BrickColor.new( "Institutional white" );

	-- Enable any temporarily-disabled selection boxes
	for _, SelectionBox in pairs( SelectionBoxes ) do
		SelectionBox.Parent = Player.PlayerGui;
	end;

	-- Call the `Equipped` listener of the current tool
	if Options.Tool and Options.Tool.Listeners.Equipped then
		Options.Tool.Listeners.Equipped();
	end;

	Mouse.KeyDown:connect( function ( key )

		local key = key:lower();
		local key_code = key:byte();

		-- Provide the abiltiy to delete via the shift + X key combination
		if ActiveKeys[47] or ActiveKeys[48] and key == "x" then
			local SelectionItems = _cloneTable( Selection.Items );
			for _, Item in pairs( SelectionItems ) do
				Item:Destroy();
			end;
			return;
		end;

		-- Provide the ability to clone via the shift + C key combination
		if ActiveKeys[47] or ActiveKeys[48] and key == "c" then

			-- Make sure that there are items in the selection
			if #Selection.Items > 0 then

				local item_copies = {};

				-- Make a copy of every item in the selection and add it to table `item_copies`
				for _, Item in pairs( Selection.Items ) do
					local ItemCopy = Item:Clone();
					ItemCopy.Parent = Services.Workspace;
					table.insert( item_copies, ItemCopy );
				end;

				-- Replace the selection with the copied items
				Selection:clear();
				for _, Item in pairs( item_copies ) do
					Selection:add( Item );
				end;

				-- Play a confirmation sound
				local Sound = RbxUtility.Create "Sound" {
					Name = "BTActionCompletionSound";
					Pitch = 1.5;
					SoundId = "http://www.roblox.com/asset/?id=99666917";
					Volume = 1;
					Parent = Player;
				};
				Sound:Play();
				Sound:Destroy();

				-- Highlight the outlines of the new parts
				coroutine.wrap( function ()
					for transparency = 1, 0, -0.1 do
						for Item, SelectionBox in pairs( SelectionBoxes ) do
							SelectionBox.Transparency = transparency;
						end;
						wait( 0.1 );
					end;
				end )();

			end;

			return;

		end;

		if key == "z" then
			Options.Tool = Tools.Move;

		elseif key == "x" then
			Options.Tool = Tools.Resize;

		elseif key == "c" then
			Options.Tool = Tools.Rotate;

		elseif key == "v" then
			Options.Tool = Tools.Paint;

		elseif key == "q" then
			Selection:clear();

		end;

		ActiveKeys[key_code] = key_code;
		ActiveKeys[key] = key;

		-- If it's now in multiselection mode, update `selecting`
		-- (these are the left/right ctrl & shift keys)
		if ActiveKeys[47] or ActiveKeys[48] or ActiveKeys[49] or ActiveKeys[50] then
			selecting = ActiveKeys[47] or ActiveKeys[48] or ActiveKeys[49] or ActiveKeys[50];
		end;

	end );

	Mouse.KeyUp:connect( function ( key )

		local key = key:lower();
		local key_code = key:byte();

		ActiveKeys[key_code] = nil;
		ActiveKeys[key] = nil;

		-- If it's no longer in multiselection mode, update `selecting`
		if selecting and not ActiveKeys[selecting] then
			selecting = false;
		end;

	end );

	Mouse.Button1Down:connect( function ()

		clicking = true;
		click_x, click_y = Mouse.X, Mouse.Y;

		-- If multiselection is, just add to the selection
		if selecting then
			return;
		end;

		-- Fire tool listeners
		if Options.Tool and Options.Tool.Listeners.Button1Down then
			Options.Tool.Listeners.Button1Down();
		end;

	end );

	Mouse.Move:connect( function ()

		-- If the target has changed, update the selectionbox appropriately
		if not override_selection and Mouse.Target then
			if Mouse.Target:IsA( "BasePart" ) and not Mouse.Target.Locked and Options.TargetBox.Adornee ~= Mouse.Target and not Selection:find( Mouse.Target ) then
				Options.TargetBox.Adornee = Mouse.Target;
			end;
		end;

		-- When aiming at something invalid, don't highlight any targets
		if not override_selection and not Mouse.Target or ( Mouse.Target and Mouse.Target:IsA( "BasePart" ) and Mouse.Target.Locked ) or Selection:find( Mouse.Target ) then
			Options.TargetBox.Adornee = nil;
		end;

		-- If spay-like multi-selecting, add this current target to the selection
		if not override_selection and selecting and clicking then
			if Mouse.Target and Mouse.Target:IsA( "BasePart" ) and not Mouse.Target.Locked then
				Selection:add( Mouse.Target );
			end;
		end;

		-- Fire tool listeners
		if Options.Tool and Options.Tool.Listeners.Move then
			Options.Tool.Listeners.Move();
		end;

		if override_selection then
			override_selection = false;
		end;

	end );

	Mouse.Button1Up:connect( function ()

		clicking = false;

		-- If the target when clicking was invalid then clear the selection (unless we're multi-selecting)
		if not override_selection and not selecting and ( not Mouse.Target or ( Mouse.Target and Mouse.Target:IsA( "BasePart" ) and Mouse.Target.Locked ) ) then
			Selection:clear();
		end;

		-- If multi-selecting, add to/remove from the selection
		if not override_selection and selecting then

			-- If the item isn't already selected, add it to the selection
			if not Selection:find( Mouse.Target ) then
				if Mouse.Target and Mouse.Target:IsA( "BasePart" ) and not Mouse.Target.Locked then
					Selection:add( Mouse.Target );
				end;
			
			-- If the item _is_ already selected, remove it from the selection
			-- (unless they're finishing a spray-like selection)
			else
				if ( Mouse.X == click_x and Mouse.Y == click_y ) and Mouse.Target and Mouse.Target:IsA( "BasePart" ) and not Mouse.Target.Locked then
					Selection:remove( Mouse.Target );
				end;
			end;

		-- If not multi-selecting, replace the selection
		else
			if not override_selection and Mouse.Target and Mouse.Target:IsA( "BasePart" ) and not Mouse.Target.Locked then
				Selection:clear();
				Selection:add( Mouse.Target );
			end;
		end;

		-- Fire tool listeners
		if Options.Tool and Options.Tool.Listeners.Button1Up then
			Options.Tool.Listeners.Button1Up();
		end;

		if override_selection then
			override_selection = false;
		end;

	end );

end );

Tool.Unequipped:connect( function ()

	Mouse = nil;

	-- Remove the mouse target SelectionBox from `Player`
	local TargetBox = Player.PlayerGui:FindFirstChild( "BTTargetBox" );
	if TargetBox then
		TargetBox:Destroy();
	end;

	-- Disable all the selection boxes temporarily
	for _, SelectionBox in pairs( SelectionBoxes ) do
		SelectionBox.Parent = nil;
	end;

	-- Call the `Unequipped` listener of the current tool
	if Options.Tool and Options.Tool.Listeners.Unequipped then
		Options.Tool.Listeners.Unequipped();
	end;

end );

-- Enable `Tools.Move` as the first tool
Options.Tool = Tools.Move;