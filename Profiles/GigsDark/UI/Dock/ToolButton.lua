local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local TextService = game:GetService('TextService')
local Sounds = Root:WaitForChild("Sounds")

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local new = Roact.createElement

-- Create component
local ToolButton = Roact.PureComponent:extend(script.Name)

function ToolButton:init()
    self:UpdateHotkeyTextSize(self.props.HotkeyLabel)
end

function ToolButton:willUpdate(nextProps)
    if self.props.HotkeyLabel ~= nextProps.HotkeyLabel then
        self:UpdateHotkeyTextSize(nextProps.HotkeyLabel)
    end
end

function ToolButton:UpdateHotkeyTextSize(Text)
    self.HotkeyTextSize = TextService:GetTextSize(
        Text,
        9,
        Enum.Font.Gotham,
        Vector2.new(math.huge, math.huge)
    )
end

function ToolButton:render()
    return new('ImageButton', {
        BackgroundColor3 = self.props.Tool.Color.Color;
		BackgroundTransparency = (self.props.CurrentTool == self.props.Tool) and 0 or self.state.Hovered and 0.7 or 1;
        BorderSizePixel = 0;
		Image = self.props.IconAssetId;
		LayoutOrder = self.props.LayoutOrder;
		[Roact.Event.Activated] = function ()
			Sounds:WaitForChild("Press"):Play()
			self.props.Core.EquipTool(self.props.Tool)
		end;
		[Roact.Event.MouseEnter] = function ()
			Sounds:WaitForChild("Hover"):Play()
			self:setState({
				Hovered = true;
			})
		end;
		[Roact.Event.MouseLeave] = function ()
			self:setState({
				Hovered = false;
			})
		end;
    }, {
        Corners = new('UICorner', {
            CornerRadius = UDim.new(0, 3);
        });
        Hotkey = new('TextLabel', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 3, 0, 3);
            Size = UDim2.fromOffset(self.HotkeyTextSize.X, self.HotkeyTextSize.Y);
            Font = Enum.Font.Gotham;
            Text = self.props.HotkeyLabel;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 9;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Top;
        });
    })
end

return ToolButton