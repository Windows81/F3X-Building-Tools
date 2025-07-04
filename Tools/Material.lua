Tool = script.Parent.Parent
Core = require(Tool.Core)
Sounds = Tool:WaitForChild("Sounds")

local Vendor = Tool:WaitForChild("Vendor")
local Libraries = Tool:WaitForChild("Libraries")

-- Libraries
local ListenForManualWindowTrigger = require(Tool.Core:WaitForChild("ListenForManualWindowTrigger"))
local Roact = require(Vendor:WaitForChild("Roact"))
local Signal = require(Libraries:WaitForChild("Signal"))

-- Import relevant references
Selection = Core.Selection
Support = Core.Support
Security = Core.Security
Support.ImportServices()

-- Initialize the tool
local MaterialTool = {
	Name = "Material Tool",
	Color = BrickColor.new("Bright violet"),

	-- State
	CurrentMaterial = nil,

	-- Signals
	OnMaterialChanged = Signal.new(),
}

MaterialTool.ManualText = [[<font face="GothamBlack" size="16">Material Tool  🛠</font>
Lets you change the material, transparency, and reflectance of parts.

<b>TIP:</b> Press <b><i>R</i></b> while hovering over a part to copy its material properties.]]

-- {PATCH} annoying boxes appear after newlines in 2021E rich text.
MaterialTool.ManualText = MaterialTool.ManualText:gsub("\n", '<font size="0">\n</font>'):gsub(
	'<font size="([0-9]+)"><br /></font>',
	'<font size="0">\n<font size="%1"> </font></font>'
)

-- Container for temporary connections (disconnected automatically)
local Connections = {}

function MaterialTool:Equip()
	-- Enables the tool's equipped functionality

	-- Start up our interface
	self:ShowUI()
	BindShortcutKeys()
end

function MaterialTool:Unequip()
	-- Disables the tool's equipped functionality

	-- Clear unnecessary resources
	self:HideUI()
	ClearConnections()
end

function ClearConnections()
	-- Clears out temporary connections

	for ConnectionKey, Connection in pairs(Connections) do
		Connection:Disconnect()
		Connections[ConnectionKey] = nil
	end
end

-- Designate a friendly name to each material
local Materials = {
	[Enum.Material.SmoothPlastic] = 'Smooth Plastic';
	[Enum.Material.Plastic] = 'Plastic';
	[Enum.Material.Brick] = 'Brick';
	[Enum.Material.Cobblestone] = 'Cobblestone';
	[Enum.Material.Concrete] = 'Concrete';
	[Enum.Material.CorrodedMetal] = 'Corroded Metal';
	[Enum.Material.DiamondPlate] = 'Diamond Plate';
	[Enum.Material.Fabric] = 'Fabric';
	[Enum.Material.Foil] = 'Foil';
	[Enum.Material.ForceField] = 'Forcefield';
	[Enum.Material.Granite] = 'Granite';
	[Enum.Material.Grass] = 'Grass';
	[Enum.Material.Ice] = 'Ice';
	[Enum.Material.Marble] = 'Marble';
	[Enum.Material.Metal] = 'Metal';
	[Enum.Material.Neon] = 'Neon';
	[Enum.Material.Pebble] = 'Pebble';
	[Enum.Material.Sand] = 'Sand';
	[Enum.Material.Slate] = 'Slate';
	[Enum.Material.Wood] = 'Wood';
	[Enum.Material.WoodPlanks] = 'Wood Planks';
	[Enum.Material.Glass] = 'Glass';
}

function MaterialTool:ShowUI()
	local UI = Tool:WaitForChild("UI")

	local Dropdown = require(UI:WaitForChild("Dropdown"))

	-- Creates and reveals the UI

	-- Reveal UI if already created
	if self.UI and self.UI.Parent ~= nil then
		-- Reveal the UI
		self.UI.Visible = true

		-- Update the UI every 0.1 seconds
		self.StopUpdatingUI = Support.Loop(0.1, function()
			self:UpdateUI()
		end)

		-- Skip UI creation
		return
	end

	if self.UI then
		self.UI:Destroy()
	end

	-- Create the UI
	self.UI = Core.Tool.Interfaces.BTMaterialToolGUI:Clone()
	self.UI.Parent = Core.UI
	self.UI.Visible = true

	-- References to inputs
	local TransparencyInput = self.UI.TransparencyOption.Input.TextBox
	local ReflectanceInput = self.UI.ReflectanceOption.Input.TextBox

	-- Sort the material list
	local MaterialList = Support.Values(Materials)
	table.sort(MaterialList)

	-- Create material dropdown
	local function BuildMaterialDropdown()
		return Roact.createElement(Dropdown, {
			Position = UDim2.new(0, 50, 0, 0),
			Size = UDim2.new(0, 130, 0, 25),
			Options = MaterialList,
			MaxRows = 6,
			CurrentOption = self.CurrentMaterial
					and typeof(self.CurrentMaterial) == "EnumItem"
					and self.CurrentMaterial.Name
				or self.CurrentMaterial,
			ImagePreview = true,
			OnOptionSelected = function(Option)
				SetProperty("Material", Support.FindTableOccurrence(Materials, Option))
			end,
		})
	end

	-- Mount surface dropdown
	local MaterialDropdownHandle = Roact.mount(BuildMaterialDropdown(), self.UI.MaterialOption, "Dropdown")
	self.OnMaterialChanged:Connect(function()
		Roact.update(MaterialDropdownHandle, BuildMaterialDropdown())
	end)

	-- Enable the transparency and reflectance inputs
	SyncInputToProperty("Transparency", TransparencyInput)
	SyncInputToProperty("Reflectance", ReflectanceInput)

	-- Hook up manual triggering
	local SignatureButton = self.UI:WaitForChild("Title"):WaitForChild("Signature")
	ListenForManualWindowTrigger(MaterialTool.ManualText, MaterialTool.Color.Color, SignatureButton)

	-- Update the UI every 0.1 seconds
	self.StopUpdatingUI = Support.Loop(0.1, function()
		self:UpdateUI()
	end)
end

function MaterialTool:HideUI()
	-- Hides the tool UI

	-- Make sure there's a UI
	if not self.UI then
		return
	end

	-- Hide the UI
	self.UI.Visible = false

	-- Stop updating the UI
	self.StopUpdatingUI()
end

function SyncInputToProperty(Property, Input)
	-- Enables `Input` to change the given property

	-- Enable inputs
	Input.FocusLost:Connect(function()
		SetProperty(Property, tonumber(Input.Text))
	end)
end

function BindShortcutKeys()
	-- Enables useful shortcut keys for this tool

	-- Track user input while this tool is equipped
	table.insert(
		Connections,
		UserInputService.InputBegan:Connect(function(InputInfo, GameProcessedEvent)
			-- Make sure this is an intentional event
			if GameProcessedEvent then
				return
			end

			-- Make sure this input is a key press
			if InputInfo.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			-- Make sure it wasn't pressed while typing
			if UserInputService:GetFocusedTextBox() then
				return
			end

			-- Check if the enter key was pressed
			if InputInfo.KeyCode == Enum.KeyCode.R then
				-- Set selection's properties to that of the target (if any)
				if Core.Mouse.Target then
					SetProperty("Material", Core.Mouse.Target.Material)
					SetProperty("Transparency", Core.Mouse.Target.Transparency)
					SetProperty("Reflectance", Core.Mouse.Target.Reflectance)
				end
			end
		end)
	)
end

function SetProperty(Property, Value)
	-- Make sure the given value is valid
	if Value == nil then
		return
	end

	-- Start a history record
	TrackChange()

	-- Go through each part
	for _, Part in pairs(Selection.Parts) do
		-- Store the state of the part before modification
		table.insert(HistoryRecord.Before, { Part = Part, [Property] = Part[Property] })

		-- Create the change request for this part
		table.insert(HistoryRecord.After, { Part = Part, [Property] = Value })
	end

	-- Register the changes
	RegisterChange()
end

function UpdateDataInputs(Data)
	-- Updates the data in the given TextBoxes when the user isn't typing in them

	-- Go through the inputs and data
	for Input, UpdatedValue in pairs(Data) do
		-- Makwe sure the user isn't typing into the input
		if not Input:IsFocused() then
			-- Set the input's value
			Input.Text = tostring(UpdatedValue)
		end
	end
end

-- List of UI layouts
local Layouts = {
	EmptySelection = { "SelectNote" },
	Normal = { "MaterialOption", "TransparencyOption", "ReflectanceOption" },
}

-- List of UI elements
local UIElements =
	{ "SelectNote", "MaterialOption", "TransparencyOption", "ReflectanceOption" }

-- Current UI layout
local CurrentLayout

function MaterialTool:ChangeLayout(Layout)
	-- Sets the UI to the given layout

	-- Make sure the new layout isn't already set
	if CurrentLayout == Layout then
		return
	end

	-- Set this as the current layout
	CurrentLayout = Layout

	-- Reset the UI
	for _, ElementName in pairs(UIElements) do
		local Element = self.UI[ElementName]
		Element.Visible = false
	end

	-- Keep track of the total vertical extents of all items
	local Sum = 0

	-- Go through each layout element
	for ItemIndex, ItemName in ipairs(Layout) do
		local Item = self.UI[ItemName]

		-- Make the item visible
		Item.Visible = true

		-- Position this item underneath the past items
		Item.Position = UDim2.new(0, 0, 0, 20) + UDim2.new(Item.Position.X.Scale, Item.Position.X.Offset, 0, Sum + 10)

		-- Update the sum of item heights
		Sum = Sum + 10 + Item.AbsoluteSize.Y
	end

	-- Resize the container to fit the new layout
	self.UI.Size = UDim2.new(0, 200, 0, 40 + Sum)
end

function MaterialTool:UpdateUI()
	-- Updates information on the UI

	-- Make sure the UI's on
	if not self.UI then
		return
	end

	-- References to inputs
	local TransparencyInput = self.UI.TransparencyOption.Input.TextBox
	local ReflectanceInput = self.UI.ReflectanceOption.Input.TextBox

	-----------------------
	-- Update the UI layout
	-----------------------

	-- Figure out the necessary UI layout
	if #Selection.Parts == 0 then
		self:ChangeLayout(Layouts.EmptySelection)
		return

	-- When the selection isn't empty
	else
		self:ChangeLayout(Layouts.Normal)
	end

	-- Get the common properties
	local Material = Support.IdentifyCommonProperty(Selection.Parts, "Material")
	local Transparency = Support.IdentifyCommonProperty(Selection.Parts, "Transparency")
	local Reflectance = Support.IdentifyCommonProperty(Selection.Parts, "Reflectance")
	local Massless = Support.IdentifyCommonProperty(Selection.Parts, "Massless")
	local CastShadow = Support.IdentifyCommonProperty(Selection.Parts, "CastShadow")

	-- Update the material dropdown
	if self.CurrentMaterial ~= Material then
		self.CurrentMaterial = Material
		self.OnMaterialChanged:Fire(Material)
	end

	-- Update inputs
	UpdateDataInputs({
		[TransparencyInput] = Transparency and Support.Round(Transparency, 2) or "*",
		[ReflectanceInput] = Reflectance and Support.Round(Reflectance, 2) or "*",
	})
end

function UpdateToggleInput(Toggle, Data)
	-- Updates the data in the given buttons

	-- Go through the inputs and data
	if Data == true then
		Toggle.Mark.Visible = true
		Toggle.Multiple.Visible = false
	elseif Data == false then
		Toggle.Mark.Visible = false
		Toggle.Multiple.Visible = false
	else
		Toggle.Mark.Visible = false
		Toggle.Multiple.Visible = true
	end
end

function TrackChange()
	-- Start the record
	HistoryRecord = {
		Before = {},
		After = {},
		Selection = Selection.Items,

		Unapply = function(Record)
			-- Reverts this change

			-- Select the changed parts
			Selection.Replace(Record.Selection)

			-- Send the change request
			Core.SyncAPI:Invoke("SyncMaterial", Record.Before)
		end,

		Apply = function(Record)
			-- Applies this change

			-- Select the changed parts
			Selection.Replace(Record.Selection)

			-- Send the change request
			Core.SyncAPI:Invoke("SyncMaterial", Record.After)
		end,
	}
end

function RegisterChange()
	-- Finishes creating the history record and registers it

	-- Make sure there's an in-progress history record
	if not HistoryRecord then
		return
	end

	-- Send the change to the server
	Core.SyncAPI:Invoke("SyncMaterial", HistoryRecord.After)

	-- Register the record and clear the staging
	Core.History.Add(HistoryRecord)
	HistoryRecord = nil
end

-- Return the tool
return MaterialTool
