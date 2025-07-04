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
        BackgroundTransparency = (self.props.CurrentTool == self.props.Tool) and 0 or 1;
        BorderSizePixel = 0;
		Image = self.props.IconAssetId;
		ImageTransparency = self.props.Position and self.props.Size and 1 or 0;
		LayoutOrder = self.props.LayoutOrder;
        AutoButtonColor = false;
		[Roact.Event.Activated] = function ()
			game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Press"))
            self.props.Core.EquipTool(self.props.Tool)
		end;
		[Roact.Event.MouseEnter] = function ()
			game:GetService("SoundService"):PlayLocalSound(Sounds:WaitForChild("Hover"))
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
			Text = '<font family="rbxassetid://12187365977">' .. self.props.HotkeyLabel .. '</font>';
			RichText = true;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            TextSize = 9;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Top;
		});
		ResizedImage = self.props.Position and self.props.Size and new('ImageLabel', {
			BackgroundTransparency = 1;
			ImageTransparency = 0;
			Image = self.props.IconAssetId;
			Position = self.props.Position;
			Size = self.props.Size;
		});
    })
end

return ToolButton