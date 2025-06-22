Tool = script.Parent.Parent;
Core = require(Tool.Core);
Sounds = Tool:WaitForChild("Sounds");

-- Libraries
local ListenForManualWindowTrigger = require(Tool.Core:WaitForChild('ListenForManualWindowTrigger'))

-- Import relevant references
Selection = Core.Selection;
Support = Core.Support;
Security = Core.Security;
Support.ImportServices();

-- Initialize the tool
local MarketplaceTool = {
	Name = 'Marketplace Tool';
	Color = BrickColor.new 'Pink';
}

MarketplaceTool.ManualText = [[<font face="GothamBlack" size="24"><u><i>Marketplace Tool  🛠</i></u></font>
Opens a catalog of images, allowing you to get image IDs quickly.<font size="6"><br /></font>

<b>TIP:</b> You can <b>Hit</b> the image you want to get their ID.]]

local SearchItem = "Decal";
local Page = 1;
local ElementsNumber = 0;
local FirstTimeEquipped = true;
local IsSearching = false;

function MarketplaceTool.Equip()
	-- Enables the tool's equipped functionality

	-- Start up our interface
	ShowUI();
	if FirstTimeEquipped == true then
		FirstTimeEquipped = false
		Page = 1
	Search("", Page, false);
	end
end;

function MarketplaceTool.Unequip()
	-- Disables the tool's equipped functionality

	-- Clear unnecessary resources
	HideUI();

end;

function ShowUI()
	-- Creates and reveals the UI

	-- Reveal UI if already created
	if MarketplaceTool.UI and MarketplaceTool.UI.Parent ~= nil then

		-- Reveal the UI
		UI.Visible = true;

		-- Update the UI every 0.1 seconds
		UIUpdater = Support.ScheduleRecurringTask(UpdateUI, 0.1);

		-- Skip UI creation
		return;

	end;
	
	if MarketplaceTool.UI then
		MarketplaceTool.UI:Destroy()
	end

	-- Create the UI
	UI = Core.Tool.Interfaces.BTMarketplaceGUI:Clone();
	UI.Parent = Core.UI;
	UI.Visible = true;

	-- References to UI elements
	local DecalButton = UI.Status.Decals.Button;
--	local MeshButton = UI.Status.Meshes.Button;
	local SearchBox = UI.Search.SearchBox.SearchInput

	-- Enable the collision status switch
	DecalButton.Activated:Connect(function ()
		game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Press"))
		SearchItem = "Decal"
		Page = 1
		Search(tostring(SearchBox.Text) or "", Page, false)
	end);
--[[	MeshButton.Activated:Connect(function ()
		Sounds:WaitForChild("Press"):Play()
		SearchItem = "Mesh"
		Page = 1
		Search(tostring(SearchBox.Text) or "", Page, false)
	end); ]]
--[[	MeshButton.MouseEnter:Connect(function ()
		Sounds:WaitForChild("Hover"):Play()
	end); ]]
	DecalButton.MouseEnter:Connect(function ()
		game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Hover"))
	end);
	
	SearchBox.Focused:Connect(function ()
		SearchBox.FocusLost:Connect(function ()
			Page = 1
			Search(tostring(SearchBox.Text) or "", Page, false)
		end);
	end);
	

	-- Hook up manual triggering
	local SignatureButton = UI:WaitForChild('Title'):WaitForChild('Signature')
	ListenForManualWindowTrigger(MarketplaceTool.ManualText, MarketplaceTool.Color.Color, SignatureButton)
	
	-- Update the UI every 0.1 seconds
	UIUpdater = Support.ScheduleRecurringTask(UpdateUI, 0.1);

end;

function UpdateUI()
	-- Updates information on the UI

	-- Make sure the UI's on
	if not UI then
		return;
	end;

	-- Check the common collision status of selection
	if UI.Search.Images.CanvasPosition.Y >= UI.Search.Images.CanvasSize.Y.Offset - UI.Search.Images.AbsoluteSize.Y and IsSearching == false then
		Page = Page + 1
		Search(tostring(UI.Search.SearchBox.SearchInput.Text) or "", Page, true)
	end
	-- Update the collision option switch
	if SearchItem == "Decal" then
		Core.ToggleSwitch('Decals', UI.Status);

	-- If the selection has collision disabled
	elseif SearchItem == "Mesh" then
		Core.ToggleSwitch('Meshes', UI.Status);
	end;

end;

function HideUI(Toggle)
	-- Hides the tool UI

	-- Make sure there's a UI
	if not UI then
		return;
	end;

	-- Hide the UI
	UI.Visible = false;

	-- Stop updating the UI
	UIUpdater:Stop();

end;

function Search(Input, Page, Cumulate)
	
	local Content, IDWasLoaded = {}, true;
	
	IsSearching = true
	
	if Cumulate == false then
		local OtherButtons = UI.Search.Images:GetChildren()
		for _, OtherElement in pairs(OtherButtons) do
			if OtherElement.Name ~= "Example" and OtherElement:IsA("Frame") then
				OtherElement:Destroy()
			end
		end
	end
	
	Content, IDWasLoaded = Core.SyncAPI:Invoke('SearchAsset', SearchItem, Input, Page) 
	
	local ItemLoaded = ElementsNumber
	
	if type(Content) == "table" then --> The value returned was a table
		for _, Data in pairs(Content) do
			
			
			
			if IsSearching == false then return end

			--> Also remove short audios to further avoid loading sound effects:

			local button = UI.Search.Images.Example:Clone()
			button.Preview.Image = "https://www.roblox.com/asset-thumbnail/image?assetId="..Data.AssetId.."&width=50&height=50&format=png"
			button.Name = "ImageNumber" .. ItemLoaded + 1
			button.ID.Text = Data.AssetId
			button.Parent = UI.Search.Images
			button.Visible = true

			--> Select audio:
			button:WaitForChild("Preview").Activated:Connect(function()

				--> Disable any other hover.
				
				local EveryOtherButtons = UI.Search.Images:GetChildren()
				
				for _, Hover in pairs(EveryOtherButtons) do
					if Hover.Name ~= "Example" and Hover:IsA("Frame") then
						Hover.ID.Visible = false
					end
				end
				
				button.ID.Visible = true

			end)

			--> Toggle audio as favourite:

			ItemLoaded += 1
			
			if ItemLoaded / 4 * 50 > UI.Search.Images.CanvasSize.Y.Offset then
--				UI.Search.Images.CanvasSize = UDim2.new(UI.Search.Images.CanvasSize.X.Scale, UI.Search.Images.CanvasSize.X.Offset, UI.Search.Images.CanvasSize.Y.Scale, UI.Search.Images.CanvasSize.Y.Offset + 50)
			end

		end

		ElementsNumber += ItemLoaded
		
		IsSearching = false

--[[	if (ElementsNumber < math.round(UI.Search.Images.AbsoluteSize.Y * 4 * 50) and not IDWasLoaded and ItemLoaded > 0) then
			canLoad = true
			checkIfPageHasEnded()
		end ]]	

		

		return ElementsNumber --> Return the number of Content loaded

	else
		warn(Content) --> Print error message to console
		
		IsSearching = false
	end
end

-- Return the tool
return MarketplaceTool;