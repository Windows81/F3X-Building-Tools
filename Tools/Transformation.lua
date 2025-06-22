Tool = script.Parent.Parent;
Core = require(Tool.Core);
Sounds = Tool:WaitForChild("Sounds");

-- Libraries
local Libraries = Tool:WaitForChild("Libraries")
local ListenForManualWindowTrigger = require(Tool.Core:WaitForChild('ListenForManualWindowTrigger'))
local Make = require(Libraries:WaitForChild("Make"))

-- Import relevant references
Selection = Core.Selection
Support = Core.Support
Security = Core.Security
Support.ImportServices()

local NegateHighlight = Make 'SelectionBox' {
	SurfaceTransparency = 0.5;
	Transparency = 1;
}
local HighlightsFolder = Instance.new("Folder", script)

-- Initialize the tool
local TransformationTool = {
	Name = 'Transformation Tool';
	Color = BrickColor.new 'Bright orange';
}

local NegativeParts = {}

TransformationTool.ManualText = [[<font face="GothamBlack" size="24"><u><i>Union Tool  🛠</i></u></font>
Allows you to create unions with this tool.<font size="6"><br /></font>

<font size="12" color="rgb(150, 150, 150)"><b>Negate</b></font>

When pressing the negate button, every selected parts will turn slightly red. This means that once the union will be created, every other non-negative selected parts in the negative parts will get truncated.

<font size="12" color="rgb(150, 150, 150)"><b>Union</b></font>

Once the union button is pressed, every parts that intersect will turn into one single part, truncated by the negative parts.
]]

function TransformationTool.Equip()
	-- Enables the tool's equipped functionality

	-- Start up our interface
	ShowUI();

end;

function TransformationTool.Unequip()
	-- Disables the tool's equipped functionality

	-- Clear unnecessary resources
	HideUI();

end;

function ShowUI()
	-- Creates and reveals the UI

	-- Reveal UI if already created
	if TransformationTool.UI and TransformationTool.UI.Parent ~= nil then

		-- Reveal the UI
		UI.Visible = true;


		UIUpdater = Support.ScheduleRecurringTask(UpdateNegativePartsDisplay, 0.1);
		-- Skip UI creation
		return;

	end;

	if TransformationTool.UI then
		TransformationTool.UI:Destroy()
	end

	-- Create the UI
	UI = Core.Tool.Interfaces.BTTransformationToolGUI:Clone();
	UI.Parent = Core.UI;
	UI.Visible = true;

	-- Hook up the buttons
	UI.Interface.NegateButton.Activated:Connect(function()
		game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Press"))
		NegateParts()
		end);
	UI.Interface.NegateButton.MouseEnter:Connect(function()
		game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Hover"))
	end);
	UI.Interface.UnionButton.Activated:Connect(function()
		game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Press"))
		CreateUnion()
	end);
	UI.Interface.UnionButton.MouseEnter:Connect(function()
		game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Hover"))
	end);

	-- Hook up manual triggering
	local SignatureButton = UI:WaitForChild('Title'):WaitForChild('Signature')
	ListenForManualWindowTrigger(TransformationTool.ManualText, TransformationTool.Color.Color, SignatureButton)

	UIUpdater = Support.ScheduleRecurringTask(UpdateNegativePartsDisplay, 0.1);
end;

function HideUI()
	-- Hides the tool UI

	-- Make sure there's a UI
	if not UI then
		return;
	end;

	-- Hide the UI
	UI.Visible = false;

	UIUpdater:Stop();

	for _, Highlight in pairs(script.Highlights:GetChildren()) do
		Highlight.Enabled = false
	end

end;

function CreateUnion()
	local NormalParts = {}
	local Negative = {}

	for _, Part in pairs(Selection.Parts) do								-- Let's class parts in two sections: Negative ones and normal ones.
		if table.find(NegativeParts, Part) then
			table.insert(Negative, Part)
		else
			table.insert(NormalParts, Part)
		end
	end

	local Unions = Core.SyncAPI:Invoke('CreateUnion', NormalParts, NegativeParts);

	for _, Union in pairs(Unions) do
		if NormalParts[Union] then
			NormalParts[Union] = nil
		end
	end

	local HistoryRecord = {
		Unions = Unions;
		NormalParts = NormalParts;
		Negative = Negative;

		Unapply = function (HistoryRecord)
			-- Reverts this change

			-- Remove the welds
			Core.SyncAPI:Invoke('Remove', HistoryRecord.Unions);
			Core.SyncAPI:Invoke('UndoRemove', HistoryRecord.NormalParts);
			Core.SyncAPI:Invoke('UndoRemove', HistoryRecord.Negative);
		end;

		Apply = function (HistoryRecord)
			-- Reapplies this change

			-- Restore the welds
			Core.SyncAPI:Invoke('UndoRemove', HistoryRecord.Unions);
			Core.SyncAPI:Invoke('Remove', HistoryRecord.NormalParts);
			Core.SyncAPI:Invoke('Remove', HistoryRecord.Negative);
		end;

	};

	Core.History.Add(HistoryRecord);

	Core.SyncAPI:Invoke('Remove', Negative);
	Core.SyncAPI:Invoke('Remove', NormalParts);

	UI.Changes.Text.Text = "The union has been successfully created."

	Selection.Replace(Unions);

	table.clear(NegativeParts)
end

function NegateParts()
	for _, Part in pairs(Selection.Parts) do
		if Support.GetChildOfClass(Part, "SpecialMesh") then continue end
		if table.find(NegativeParts, Part) then
			NegativeParts[table.find(NegativeParts, Part)] = nil
			for _, Highlight in pairs(script.Highlights:GetChildren()) do
				if Highlight.Adornee == Part then
					Highlight:Destroy()
				end
			end
			continue
		end
		table.insert(NegativeParts, Part)
		local PartHighlight = NegateHighlight:Clone()
		PartHighlight.Parent = HighlightsFolder
		PartHighlight.Adornee = Part
	end;
end

function UpdateNegativePartsDisplay()
	for i, Part in pairs(NegativeParts) do
		if Support.GetChildOfClass(Part, "SpecialMesh") or Part.Parent == nil or Part == nil then
			NegativeParts[Part] = nil
			for _, Highlight in pairs(script.Highlights:GetChildren()) do
				if Highlight.Adornee == Part then
					Highlight:Destroy()
				end
			end
			continue
		end
		for _, Highlight in pairs(script.Highlights:GetChildren()) do
			if Highlight.Adornee == Part then
				Highlight.Enabled = true
			elseif Highlight.Adornee == nil or Highlight.Adornee.Parent == nil then
				Highlight:Destroy()
			end
		end
	end
	for _, Highlight in pairs(script.Highlights:GetChildren()) do
		if Highlight.Adornee == nil or Highlight.Adornee.Parent == nil then
			Highlight:Destroy()
		end
	end
end

-- Return the tool
return TransformationTool;