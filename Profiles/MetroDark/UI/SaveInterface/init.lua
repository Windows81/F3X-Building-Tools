local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local Libraries = Root:WaitForChild("Libraries")

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local Maid = require(Libraries:WaitForChild("Maid"))
local new = Roact.createElement

local ColorBar = require(script.ColorBar)
local Interface = require(script.Interface)

local ExportDialog = Roact.PureComponent:extend(script.Name)

function ExportDialog:init()
	self.Maid = Maid.new()
	self.PaneSize, self.SetPaneSize = Roact.createBinding(UDim2.new())

	self:UpdateSaveLoadState()
	self.Maid.TrackSaveLoad = self.props.Core.SaveLoadVisibilityChanged:Connect(function ()
		self:UpdateSaveLoadState()
	end)
end

function ExportDialog:UpdateSaveLoadState()
	self:setState({
		IsSaveLoadOpen = self.props.Core.SaveLoadVisible;
	})
end

function ExportDialog:render(props)
	return new('ScreenGui', {}, {
		FrameWithEverthingInside = new('Frame', {
			AnchorPoint = Vector2.new(0.5, 0.5);
			BackgroundColor3 = Color3.fromRGB(0, 0, 0);
			BackgroundTransparency = 0.7;
			BorderSizePixel = 0;
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Size = UDim2.new(0.4, 0, 0.5, 0);
			Visible = self.state.IsSaveLoadOpen;
		}, {
			Corners = new('UICorner', {
				CornerRadius = UDim.new(0.02, 0);
			});
			AspectRatio = new('UIAspectRatioConstraint', {
				AspectRatio = 1.5;
				AspectType = Enum.AspectType.ScaleWithParentSize;
				DominantAxis = Enum.DominantAxis.Height;
			});
			LeftColorBar = new(ColorBar, {
				AnchorPoint = Vector2.new(0, 0);
				Position = UDim2.new(0, 0, 0.043, 0);
			});
			RightColorBar = new(ColorBar, {
				AnchorPoint = Vector2.new(1, 0);
				Position = UDim2.new(1, 0, 0.043, 0);
			});
			Interface = new(Interface, {
				FirstSaveLoad = self.props.FirstSaveLoad;
				FirstSave = self.props.FirstSave;
				SecondSaveLoad = self.props.SecondSaveLoad;
				SecondSave = self.props.SecondSave;
				ThirdSaveLoad = self.props.ThirdSaveLoad;
				ThirdSave = self.props.ThirdSave;
			});
		});
	})
end

return ExportDialog