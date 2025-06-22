local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local Libraries = Root:WaitForChild('Libraries')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local Cryo = require(Libraries:WaitForChild('Cryo'))
local Support = require(Libraries:WaitForChild("SupportLibrary"))
local MaterialsImages = require(Libraries:WaitForChild("MaterialsLibrary"))
local Tools = Root:WaitForChild("Tools")
local new = Roact.createElement

-- Create component
local Dropdown = Roact.PureComponent:extend(script.Name)

function Dropdown:init()
	self.Size, self.SetSize = Roact.createBinding(Vector2.new())
	self:setState({
		AreOptionsVisible = false;
	})
end

function Dropdown:BuildButtonList()
	local List = {}
	for _, Option in ipairs(self.props.Options) do
		table.insert(List, new('TextButton', {
			BackgroundTransparency = (self.props.CurrentOption == Option) and 0.1 or 1;
			BackgroundColor3 = Color3.fromRGB(0, 145, 255);
			BorderSizePixel = 0;
			Font = Enum.Font.GothamBold;
			Text = Option;
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextSize = 10;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Center;
			ZIndex = 3;
			[Roact.Event.MouseEnter] = function (rbx)
				rbx.BackgroundTransparency = 0.2
			end;
			[Roact.Event.InputEnded] = function (rbx)
				rbx.BackgroundTransparency = (self.props.CurrentOption == Option) and 0.1 or 1
			end;
			[Roact.Event.Activated] = function (rbx)
				self:setState({
					AreOptionsVisible = false;
				})
				self.props.OnOptionSelected(Option)
			end;
		}, {
			Padding = new('UIPadding', {
				PaddingLeft = UDim.new(0, 6);
				PaddingRight = UDim.new(0, 6);
			});
			Corners = new('UICorner', {
				CornerRadius = UDim.new(0, 4);
			});
			ImagePreview = self.props.ImagePreview and new('ImageLabel', {
				BackgroundTransparency = 0;
				BackgroundColor3 = Color3.fromRGB(120, 120, 120);
				BorderSizePixel = 0;
				Image = tonumber(MaterialsImages[Option]) and "rbxassetid://" .. MaterialsImages[Option] or MaterialsImages[Option] or "rbxasset://Textures/ui/dialog_purpose_help.png";
				AnchorPoint = Vector2.new(1, 0.5);
				Position = UDim2.new(1, 0, 0.5, 0);
				Size = UDim2.new(0, 20, 0, 20);
				ZIndex = 3;
				ScaleType = Enum.ScaleType.Tile;
				TileSize = MaterialsImages[Option] and UDim2.new(2, 0, 2, 0) or UDim2.new(1, 0, 1, 0);
			}) or nil;
			TextPreview = self.props.TextPreview and new('TextLabel', {
				BackgroundTransparency = 1;
				BorderSizePixel = 0;
				Text = "A";
				TextScaled = true;
				AnchorPoint = Vector2.new(1, 0.5);
				Position = UDim2.new(1, 0, 0.5, 0);
				Size = UDim2.new(0, 20, 0, 20);
				TextColor3 = Color3.fromRGB(255, 255, 255);
				ZIndex = 3;
				Font = self.props.OccurrenceOptions and Support.FindTableOccurrence(self.props.OccurrenceOptions, Option) or Enum.Font.Arimo
			}) or nil;
		}))
	end
	return List
end

function Dropdown:render()
	return new('ImageButton', {
		BackgroundColor3 = Color3.new(1, 1, 1);
		BackgroundTransparency = 0.9;
		BorderSizePixel = 0;
		Position = self.props.Position;
		Size = self.props.Size;
		Image = '';
		[Roact.Change.AbsoluteSize] = function (rbx)
			self.SetSize(rbx.AbsoluteSize)
		end;
		[Roact.Event.Activated] = function (rbx)
			self:setState({
				AreOptionsVisible = not self.state.AreOptionsVisible;
			})
		end;
	}, {
		Corners = new('UICorner', {
			CornerRadius = UDim.new(0, 4);
		});
		Stroke = new('UIStroke', {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			Transparency = 0.9;
			Thickness = 2;
			Color = Color3.new(0, 0, 0);
		});
		CurrentOption = new('TextLabel', {
			BackgroundTransparency = 1;
			Font = Enum.Font.GothamBold;
			Text = self.props.CurrentOption or '*';
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextSize = 10;
			TextXAlignment = Enum.TextXAlignment.Left;
			TextYAlignment = Enum.TextYAlignment.Center;
			Position = UDim2.new(0, 6, 0, 0);
			Size = UDim2.new(1, -32, 1, 0);
		});
		Arrow = new('ImageLabel', {
			BackgroundTransparency = 1;
			AnchorPoint = Vector2.new(1, 0.5);
			Position = UDim2.new(1, -3, 0.5, 0);
			Size = UDim2.new(0, 20, 0, 20);
			Image = 'rbxassetid://11552476728';
		});
		ScrollFrame = new('ScrollingFrame', {
			Visible = self.state.AreOptionsVisible;
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BackgroundTransparency = 1;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 0, 1, 5);
			Size = UDim2.new(
				math.clamp(math.ceil(#self.props.Options / self.props.MaxRows), 0, 3), 0,
				(#self.props.Options > self.props.MaxRows) and self.props.MaxRows or #self.props.Options, math.ceil(#self.props.Options / self.props.MaxRows) <= 3 and 12 or 0
			);
			ZIndex = 2;
			AutomaticCanvasSize = Enum.AutomaticSize.None;
			CanvasSize = UDim2.new(
				math.ceil(#self.props.Options / self.props.MaxRows), 0,
				(#self.props.Options > self.props.MaxRows) and self.props.MaxRows or #self.props.Options, 0
			);
			ScrollingDirection = Enum.ScrollingDirection.X;
			ScrollBarImageColor3 = require(Root.Core.Selection).Color.Color ~= Color3.fromRGB(255, 255, 255) and require(Root.Core.Selection).Color.Color or Color3.new(17 / 255, 17 / 255, 17 / 255);
			TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
			BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png";
		}, Cryo.Dictionary.join(self:BuildButtonList(), {
			Layout = new('UIGridLayout', {
				CellPadding = UDim2.new();
				CellSize = UDim2.new(1 / math.ceil(#self.props.Options / self.props.MaxRows), 0, 1 / self.props.MaxRows, math.ceil(#self.props.Options / self.props.MaxRows) >= 3 and -12 / self.props.MaxRows or 0);
				FillDirection = Enum.FillDirection.Vertical;
				FillDirectionMaxCells = self.props.MaxRows;
				HorizontalAlignment = Enum.HorizontalAlignment.Left;
				VerticalAlignment = Enum.VerticalAlignment.Top;
				SortOrder = Enum.SortOrder.LayoutOrder;
				StartCorner = Enum.StartCorner.TopLeft;
			});
		}));
		Options = new('Frame', {
			Visible = self.state.AreOptionsVisible;
			BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BackgroundTransparency = 0.6;
			BorderSizePixel = 0;
			Position = UDim2.new(0, 0, 1, 5);
			Size = UDim2.new(
				math.clamp(math.ceil(#self.props.Options / self.props.MaxRows), 0, 3), 0,
				(#self.props.Options > self.props.MaxRows) and self.props.MaxRows or #self.props.Options, math.ceil(#self.props.Options / self.props.MaxRows) <= 3 and 12 or 0
			);
			ZIndex = 2;
		}, {
			Corners = new('UICorner', {
				CornerRadius = UDim.new(0, 4);
			});
			Stroke = new('UIStroke', {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
				Transparency = 0.9;
				Thickness = 2;
				Color = Color3.new(0, 0, 0);
			});
		});
	})
end

return Dropdown

				--[[self.Size:map(function (Size)
					print(Size)
					print(UDim2.fromOffset(Size.X, Size.Y))
                    return UDim2.fromOffset(Size.X, Size.Y)
                end);]]