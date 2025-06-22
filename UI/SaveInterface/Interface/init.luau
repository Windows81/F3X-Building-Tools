local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))

-- Roact
local new = Roact.createElement
local Slot = require(script.Slot)

-- Create component
local Interface = Roact.PureComponent:extend(script.Name)

function GetColorBars(Colors)
	-- TODO: Return every color frames that are needed to create the color bar.
	local ColorFrames = {}

	for i, Color in pairs(Colors) do
		local RoactItem = new("Frame", {
			BackgroundColor3 = Color
		})
		ColorFrames["Color" .. i] = RoactItem
	end

	for _, ColorFrame in pairs(ColorFrames) do

	end
end

function Interface:render()
	local props = self.props
	-- Calculating what needs to be calculated
	return new('Frame', {
		Active = true;
		AnchorPoint = Vector2.new(0.5, 0.5);
		BackgroundTransparency = 1;
		Position = UDim2.new(0.5, 0, 0.5, 0);
		Size = UDim2.new(0.996, -2, 0.914, 0);
	}, {
		Slots = new('Frame', {
			Active = true;
			AnchorPoint = Vector2.new(0.5, 1);
			BackgroundTransparency = 1;
			Position = UDim2.new(0.5, 0, 1, 0);
			Size = UDim2.new(0.9, 0, 0.8, 0);
		}, {
			Slot1 = new(Slot, {
				SlotName = "Slot 1";
				LayoutOrder = 1;
				SaveFunction = props.FirstSave;
				LoadFunction = props.FirstSaveLoad;
			});
			Slot2 = new(Slot, {
				SlotName = "Slot 2";
				LayoutOrder = 2;
				SaveFunction = props.SecondSave;
				LoadFunction = props.SecondSaveLoad;
			});
			Slot3 = new(Slot, {
				SlotName = "Slot 3";
				LayoutOrder = 3;
				SaveFunction = props.ThirdSave;
				LoadFunction = props.ThirdSaveLoad;
			});
			Layout = new('UIGridLayout', {
				CellPadding = UDim2.new(0, 0, 0.133, 0);
				CellSize = UDim2.new(1, 0, 0.2, 0);
				FillDirection = Enum.FillDirection.Vertical;
				HorizontalAlignment = Enum.HorizontalAlignment.Left;
				VerticalAlignment = Enum.VerticalAlignment.Center;
				SortOrder = Enum.SortOrder.LayoutOrder;
			});
		});
		Instructions = new('TextLabel', {
			Active = true;
			AnchorPoint = Vector2.new(0, 0);
			BackgroundTransparency = 1;
			Position = UDim2.new(0.05, 0, 0.1, 0);
			Size = UDim2.new(0.95, 0, 0.05, 0);
			Font = Enum.Font.Arimo;
			Text = "You can save a build or load a build among the three slots avalaible.";
			TextScaled = true;
			TextStrokeTransparency = 0;
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Left;
		});
		Title = new('TextLabel', {
			Active = true;
			AnchorPoint = Vector2.new(0, 0);
			BackgroundTransparency = 1;
			Position = UDim2.new(0.05, 0, 0, 0);
			Size = UDim2.new(0.95, 0, 0.1, 0);
			Font = Enum.Font.Arimo;
			RichText = true;
			Text = "<b>Save/Load Interface:</b>";
			TextScaled = true;
			TextStrokeTransparency = 0;
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Left;
		});
	})
end

return Interface
