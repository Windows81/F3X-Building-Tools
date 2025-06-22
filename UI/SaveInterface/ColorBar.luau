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
		AnchorPoint = props.AnchorPoint;
		BackgroundTransparency = 1;
		Position = props.Position;
		Size = UDim2.new(0.002, 1, 0.914, 0);
	}, {
		Layout = new('UIGridLayout', {
			CellPadding = UDim2.new(0, 0, 0, 0);
			CellSize = UDim2.new(1, 0, (1 / 9), 0);
			FillDirection = Enum.FillDirection.Vertical;
			HorizontalAlignment = Enum.HorizontalAlignment.Left;
			VerticalAlignment = Enum.VerticalAlignment.Top;
			SortOrder = Enum.SortOrder.LayoutOrder;
		});
		Yellow = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(244, 205, 47);
			BorderSizePixel = 0;
			LayoutOrder = 0;
		});
		Blue = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(4, 175, 235);
			BorderSizePixel = 0;
			LayoutOrder = 1;
		});
		Green = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(75, 151, 75);
			BorderSizePixel = 0;
			LayoutOrder = 2;
		});
		Red = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 0, 0);
			BorderSizePixel = 0;
			LayoutOrder = 3;
		});
		Purple = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(107, 49, 124);
			BorderSizePixel = 0;
			LayoutOrder = 4;
		});
		Black = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0);
			BorderSizePixel = 0;
			LayoutOrder = 5;
		});
		Pink = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 102, 204);
			BorderSizePixel = 0;
			LayoutOrder = 6;
		});
		BrightestYellow = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 0);
			BorderSizePixel = 0;
			LayoutOrder = 7;
		});
		Orange = new("Frame", {
			BackgroundColor3 = Color3.fromRGB(218, 133, 65);
			BorderSizePixel = 0;
			LayoutOrder = 8;
		});
	})
end

return Interface
