local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local Sounds = Root:WaitForChild("Sounds")

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))

-- Roact
local new = Roact.createElement
local Tooltip = require(script.Parent:WaitForChild('Tooltip'))

-- Create component
local SelectionButton = Roact.PureComponent:extend(script.Name)

function SelectionButton:init()
    self:setState({
        IsHovering = false;
    })
end

function SelectionButton:render()
	return new('ImageButton', {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		BackgroundTransparency = self.state.IsHovering and 0.7 or 1;
        Image = self.props.IconAssetId;
        LayoutOrder = self.props.LayoutOrder;
        ImageTransparency = self.props.IsActive and 0 or 0.5;
		[Roact.Event.Activated] = function()
			Sounds:WaitForChild("Press"):Play()
			self.props.OnActivated()
		end;
        [Roact.Event.InputBegan] = function (rbx, Input)
            if Input.UserInputType.Name == 'MouseMovement' then
				self:setState({
					Sounds:WaitForChild("Hover"):Play();
                    IsHovering = true;
                })
            end
        end;
        [Roact.Event.InputEnded] = function (rbx, Input)
            if Input.UserInputType.Name == 'MouseMovement' then
                self:setState({
                    IsHovering = false;
                })
            end
        end;
    }, {
        Tooltip = new(Tooltip, {
            IsVisible = self.state.IsHovering;
            Text = self.props.TooltipText or '';
		});
		Corners = new('UICorner', {
			CornerRadius = UDim.new(0, 3);
		});
    });
end


return SelectionButton