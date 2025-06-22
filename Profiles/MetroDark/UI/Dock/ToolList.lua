local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local Libraries = Root:WaitForChild('Libraries')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local Maid = require(Libraries:WaitForChild('Maid'))

-- Roact
local new = Roact.createElement
local ToolButton = require(script.Parent:WaitForChild('ToolButton'))
local ToolButtonAdjusted = require(script.Parent:WaitForChild('ToolButtonWithResizedImage'))

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
			CellSize = UDim2.new(0.5, 0, 0.111, 0);
            FillDirection = Enum.FillDirection.Horizontal;
            FillDirectionMaxCells = 2;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Top;
            SortOrder = Enum.SortOrder.LayoutOrder;
            StartCorner = Enum.StartCorner.TopLeft;
    --        [Roact.Ref] = function (rbx)
    --            if rbx then
    --                self.SetCanvasSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
    --            end
    --        end;
    --        [Roact.Change.AbsoluteContentSize] = function (rbx)
    --            self.SetCanvasSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
	--        end;
		});
    }

    -- Build buttons for each tool
	for ToolIndex, ToolInfo in ipairs(self.props.Tools) do
		if ToolInfo.Tool.Name ~= "Marketplace Tool" and ToolInfo.Tool.Name ~= "Text Tool" and ToolInfo.Tool.Name ~= "Transformation Tool" and ToolInfo.Tool.Name ~= "Attachment Tool" then
        Children[tostring(ToolIndex)] = new(ToolButton, {
            CurrentTool = self.state.CurrentTool;
            IconAssetId = ToolInfo.IconAssetId;
            HotkeyLabel = ToolInfo.HotkeyLabel;
            Tool = ToolInfo.Tool;
            Core = self.props.Core;
		})
		elseif ToolInfo.Tool.Name == "Marketplace Tool" then
			Children[tostring(ToolIndex)] = new(ToolButtonAdjusted, {
				CurrentTool = self.state.CurrentTool;
				IconAssetId = ToolInfo.IconAssetId;
				HotkeyLabel = ToolInfo.HotkeyLabel;
				Tool = ToolInfo.Tool;
				Core = self.props.Core;
				Size = UDim2.new(0.55, 0, 0.55, 0);
				Position = UDim2.new(0.225, 0, 0.175, 0);
			})	
		elseif ToolInfo.Tool.Name == "Text Tool" then
			Children[tostring(ToolIndex)] = new(ToolButtonAdjusted, {
				CurrentTool = self.state.CurrentTool;
				IconAssetId = ToolInfo.IconAssetId;
				HotkeyLabel = ToolInfo.HotkeyLabel;
				Tool = ToolInfo.Tool;
				Core = self.props.Core;
				Size = UDim2.new(0.45, 0, 0.45, 0);
				Position = UDim2.new(0.275, 0, 0.275, 0);
			})	
		elseif ToolInfo.Tool.Name == "Transformation Tool" then
			Children[tostring(ToolIndex)] = new(ToolButtonAdjusted, {
				CurrentTool = self.state.CurrentTool;
				IconAssetId = ToolInfo.IconAssetId;
				HotkeyLabel = ToolInfo.HotkeyLabel;
				Tool = ToolInfo.Tool;
				Core = self.props.Core;
				Size = UDim2.new(0.55, 0, 0.55, 0);
				Position = UDim2.new(0.225, 0, 0.175, 0);
			})	
		elseif ToolInfo.Tool.Name == "Attachment Tool" then
			Children[tostring(ToolIndex)] = new(ToolButtonAdjusted, {
				CurrentTool = self.state.CurrentTool;
				IconAssetId = ToolInfo.IconAssetId;
				HotkeyLabel = ToolInfo.HotkeyLabel;
				Tool = ToolInfo.Tool;
				Core = self.props.Core;
				Size = UDim2.new(0.55, 0, 0.55, 0);
				Position = UDim2.new(0.225, 0, 0.175, 0);
			})	
		end
		end

    return new('Frame', {
        BackgroundTransparency = 0.6;
        BackgroundColor3 = Color3.fromRGB(0, 0, 0);
        BorderSizePixel = 0;
        LayoutOrder = self.props.LayoutOrder;
		Size = UDim2.new(1, 0, 0.575, 0)
    }, {
        Corners = new('UICorner', {
			CornerRadius = UDim.new(0.0428571428571429, 0);
        });
        List = new('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            CanvasSize = self.CanvasSize;
            ScrollBarThickness = 1;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0);
            [Roact.Children] = Children;
        });
    })
end

return ToolList