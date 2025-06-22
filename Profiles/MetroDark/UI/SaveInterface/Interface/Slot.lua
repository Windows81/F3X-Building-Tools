local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))

-- Roact
local new = Roact.createElement

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
		BackgroundTransparency = 0.5;
		BackgroundColor3 = Color3.fromRGB(0, 0, 0);
		LayoutOrder = props.LayoutOrder;
	}, {
		Corners = new('UICorner', {
			CornerRadius = UDim.new(0.138, 0);
		});
		Title = new('TextLabel', {
			Active = true;
			AnchorPoint = Vector2.new(0, 0.5);
			BackgroundTransparency = 1;
			Position = UDim2.new(0, 0, 0.5, 0);
			Size = UDim2.new(0.3, 0, 0.6, 0);
			Font = Enum.Font.Arimo;
			RichText = true;
			Text = "<b>" .. props.SlotName .. "</b>";
			TextScaled = true;
			TextStrokeTransparency = 0;
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Center;
		});
		LoadButton = new("ImageButton",{
			Active = true;
			AnchorPoint = Vector2.new(1, 0.5);
			AutoButtonColor = true;
			BackgroundTransparency = 1;
			Position = UDim2.new(0.87, 0, 0.45, 0);
			Size = UDim2.new(0.7, 0, 0.65, 0);
			Image = "rbxassetid://83856799245957";
			Selectable = true;
			[Roact.Event.Activated] = props.LoadFunction;
		}, {
			AspectRatio = new('UIAspectRatioConstraint', {
				AspectRatio = 1;
				AspectType = Enum.AspectType.FitWithinMaxSize;
				DominantAxis = Enum.DominantAxis.Width;
			});
		});
		SaveButton = new("ImageButton",{
			Active = true;
			AnchorPoint = Vector2.new(1, 0.5);
			AutoButtonColor = true;
			BackgroundTransparency = 1;
			Position = UDim2.new(0.97, 0, 0.5, 0);
			Size = UDim2.new(0.7, 0, 0.7, 0);
			Image = "rbxassetid://12392896984";
			Selectable = true;
			[Roact.Event.Activated] = props.SaveFunction;
		}, {
			AspectRatio = new('UIAspectRatioConstraint', {
				AspectRatio = 1;
				AspectType = Enum.AspectType.FitWithinMaxSize;
				DominantAxis = Enum.DominantAxis.Width;
			});
		});
	})
end

return Interface
