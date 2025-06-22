local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local Libraries = Root:WaitForChild('Libraries')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local Maid = require(Libraries:WaitForChild('Maid'))

-- Roact
local new = Roact.createElement
local ToolList = require(script:WaitForChild('ToolList'))
local SelectionPane = require(script:WaitForChild('SelectionPane'))
local SpecialSelectionPane = require(script:WaitForChild('SpecialSelectionPane'))
local AboutPane = require(script:WaitForChild('AboutPane'))

-- Create component
local Dock = Roact.PureComponent:extend(script.Name)

function Dock:init()
	self.Maid = Maid.new()
	self.DockSize, self.SetDockSize = Roact.createBinding(UDim2.new())
	self.DockScale, self.SetDockScale = Roact.createBinding(UDim2.new())
	
	local Camera = workspace.Camera
	
	self:UpdateDockScale()
	self.Maid.ChangeSize = workspace.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		self:UpdateDockScale()
	end)
end

function Dock:UpdateDockScale()
	local Camera = workspace.Camera
	self.SetDockSize(UDim2.fromOffset(math.clamp(105 + math.clamp(math.ceil((540 - Camera.ViewportSize.Y) / 100), 0, 3) * 35, 105, 240), 0))
	self.SetDockScale(math.clamp(1 - math.max(516 - Camera.ViewportSize.Y, 0) / 456, 0.5, 1));
end

function Dock:render()
    return new('Frame', {
        Active = true;
        AnchorPoint = Vector2.new(1, 1);
        BackgroundTransparency = 1;
        Position = UDim2.new(1, -4, 1, -58);
		Size = self.DockSize;
		--Size = self.DockSize:map(function(DockSize)
		--	return DockSize
		--end);
        ZIndex = 0;
		AutomaticSize = Enum.AutomaticSize.Y;
    }, {
		Scale = new('UIScale', {
			Scale = self.DockScale;
		}),
		Layout = new('UIListLayout', {
			Padding =  UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Top;
            SortOrder = Enum.SortOrder.LayoutOrder;
            [Roact.Ref] = function (rbx)
                --if rbx then
                --    self.SetDockSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
                --end
            end;
            [Roact.Change.AbsoluteContentSize] = function (rbx)
                --self.SetDockSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
            end;
        });
        ToolList = new(ToolList, {
            LayoutOrder = 0;
            Tools = self.props.Tools;
            Core = self.props.Core;
        });
        SelectionPane = new(SelectionPane, {
            LayoutOrder = 1;
            Core = self.props.Core;
        });
		SpecialSelectionPane = if (not game:GetService("UserInputService").KeyboardEnabled) then new(SpecialSelectionPane, {
			LayoutOrder = 2;
			Core = self.props.Core;
		}) else nil;
        AboutPane = new(AboutPane, {
            LayoutOrder = 3;
            Core = self.props.Core;
		});
	
	})
end

return Dock