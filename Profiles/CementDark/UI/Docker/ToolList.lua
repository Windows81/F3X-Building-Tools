local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local Libraries = Root:WaitForChild('Libraries')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local Maid = require(Libraries:WaitForChild('Maid'))

-- Roact
local new = Roact.createElement
local ToolButton = require(script.Parent:WaitForChild('ToolButton'))

-- Create component
local ToolList = Roact.PureComponent:extend(script.Name)

function ToolList:init()
    self.Maid = Maid.new()
    self.CanvasSize, self.SetCanvasSize = Roact.createBinding(UDim2.new())

    -- Track current tool
    self:setState({
        CurrentTool = self.props.Core.CurrentTool;
    })
    self.Maid.CurrentTool = self.props.Core.ToolChanged:Connect(function (Tool)
        self:setState({
            CurrentTool = Tool;
        })
    end)
end

function ToolList:render()
    local Children = {
        Layout = new('UIGridLayout', {
            CellPadding = UDim2.new(0, 0, 0, 0);
            CellSize = UDim2.new(0, 35, 0, 35);
            FillDirection = Enum.FillDirection.Horizontal;
            FillDirectionMaxCells = 0;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Top;
            SortOrder = Enum.SortOrder.LayoutOrder;
            StartCorner = Enum.StartCorner.TopLeft;
            [Roact.Ref] = function (rbx)
                if rbx then
                    self.SetCanvasSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
                end
            end;
            [Roact.Change.AbsoluteContentSize] = function (rbx)
                self.SetCanvasSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
            end;
        });
    }

    -- Build buttons for each tool
    for ToolIndex, ToolInfo in ipairs(self.props.Tools) do
        Children[tostring(ToolIndex)] = new(ToolButton, {
            CurrentTool = self.state.CurrentTool;
            IconAssetId = ToolInfo.IconAssetId;
            HotkeyLabel = ToolInfo.HotkeyLabel;
			Tool = ToolInfo.Tool;
			Position = ToolInfo.Position;
			Size = ToolInfo.Size;
            Core = self.props.Core;
        })
    end

    return new('Frame', {
        BackgroundTransparency = 0.5;
		BackgroundColor3 = Color3.new(0.0666667, 0.0705882, 0.0862745);
        BorderSizePixel = 0;
        LayoutOrder = self.props.LayoutOrder;
		Size = self.CanvasSize:map(function (CanvasSize)
			return UDim2.fromScale(1, 0)
        end);
		AutomaticSize = Enum.AutomaticSize.Y;
    }, {
		Corners = new('UICorner', {
			CornerRadius = UDim.new(0.5 / 3, 1);
		});
		Stroke = new('UIStroke', {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			Color = Color3.fromHex("313339");
			Transparency = 0;
		});
        SizeConstraint = new('UISizeConstraint', {
            MinSize = Vector2.new(70, 0);
        });
        List = new('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            CanvasSize = UDim2.new();
			AutomaticSize = Enum.AutomaticSize.Y;
            ScrollBarThickness = 1;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
            [Roact.Children] = Children;
        });
    })
end

return ToolList