local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local UI = Root:WaitForChild('UI')
local Libraries = Root:WaitForChild('Libraries')
local UserInputService = game:GetService('UserInputService')
local GuiService = game:GetService('GuiService')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local Maid = require(Libraries:WaitForChild('Maid'))

-- Roact
local new = Roact.createElement
local ToolManualWindow = require(UI:WaitForChild('ToolManualWindow'))

local MANUAL_CONTENT = [[<font face="GothamBlack" size="16">Fork3X, based on F3X's work, by Vikko151  🛠</font>
To learn more about each tool, click on its ❔ icon at the top right corner.<font size="12"><br /></font>

<font size="12" color="rgb(150, 150, 150)"><b>Selecting</b></font>
 <font color="rgb(150, 150, 150)">•</font> Select individual parts by holding <b>Shift</b> and clicking each one.
 <font color="rgb(150, 150, 150)">•</font> Rectangle select parts by holding <b>Shift</b>, clicking, and dragging.
 <font color="rgb(150, 150, 150)">•</font> Press <b>Shift-K</b> to select parts inside of the selected parts.
 <font color="rgb(150, 150, 150)">•</font> Press <b>Shift-R</b> to clear your selection.<font size="12"><br /></font>
<font size="12" color="rgb(150, 150, 150)"><b>Grouping</b></font>
<font color="rgb(150, 150, 150)">•</font> Group parts as a <i>model</i> by pressing <b>Shift-G</b>.
<font color="rgb(150, 150, 150)">•</font> Group parts into a <i>folder</i> by pressing <b>Shift-F</b>.
<font color="rgb(150, 150, 150)">•</font> Ungroup parts by pressing <b>Shift-U</b>.<font size="12"><br /></font>
<font size="12" color="rgb(150, 150, 150)"><b>Exporting your creations</b></font>
You can export your builds into a short code by clicking the export button, or pressing <b>Shift-P</b>.<font size="8"><br /></font>
Install the import plugin in <b>Roblox Studio</b> to import your creation:
<font color="rgb(150, 150, 150)">roblox.com/library/142485815</font>]]

-- Create component
local AboutPane = Roact.PureComponent:extend(script.Name)

function AboutPane:init()
	self.DockSize, self.SetDockSize = Roact.createBinding(UDim2.new())
	self.Maid = Maid.new()

	self:UpdateColor()
	self.Maid.TrackHistory = self.props.Core.ToolChanged:Connect(function (Tool)
		self:UpdateColor(Tool)
	end)
end

function AboutPane:UpdateColor(Tool)
	if Tool and Tool.Color then
		self:setState({
			Color = Tool.Color.Color;
		})
	end
end


function AboutPane:willUnmount()
	self.Maid:Destroy()
end

function AboutPane:render()
	return new('Frame', {
		BackgroundTransparency = 1;
		BackgroundColor3 = Color3.fromRGB(0, 0, 0);
		LayoutOrder = self.props.LayoutOrder;
		Size = UDim2.new(1, 0, 0, 32);
		ClipsDescendants = true;
		ZIndex = 2;
	}, {
		Button = new('ImageButton', {
			Image = '';
			BackgroundTransparency = 0;
			BackgroundColor3 = self.state.Color;
			LayoutOrder = self.props.LayoutOrder;
			Size = UDim2.new(1, 0, 1, 8);
			[Roact.Event.Activated] = function (rbx)
				self:setState({
					IsManualOpen = not self.state.IsManualOpen;
				})
			end;
			[Roact.Event.MouseButton1Down] = function (rbx)
				local Dock = rbx.Parent.Parent
				local InitialAbsolutePosition = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
				local InitialPosition = Dock.Position

				self.Maid.DockDragging = UserInputService.InputChanged:Connect(function (Input)
					if (Input.UserInputType.Name == 'MouseMovement') or (Input.UserInputType.Name == 'Touch') then

						-- Suppress activation response if dragging detected
						if (Vector2.new(Input.Position.X, Input.Position.Y) - InitialAbsolutePosition).Magnitude > 3 then
							rbx.Active = false
						end

						-- Reposition dock
						Dock.Position = UDim2.new(
							InitialPosition.X.Scale,
							InitialPosition.X.Offset + (Input.Position.X - InitialAbsolutePosition.X),
							InitialPosition.Y.Scale,
							InitialPosition.Y.Offset + (Input.Position.Y - InitialAbsolutePosition.Y)
						)
					end
				end)

				self.Maid.DockDraggingEnd = UserInputService.InputEnded:Connect(function (Input)
					if (Input.UserInputType.Name == 'MouseButton1') or (Input.UserInputType.Name == 'Touch') then
						self.Maid.DockDragging = nil
						self.Maid.DockDraggingEnd = nil
						rbx.Active = true
					end
				end)
			end;
			ZIndex = 2;
		}, {
			Corners = new('UICorner', {
				CornerRadius = UDim.new(0.09375, 0);
			});
			Signature = new('TextLabel', {
				AnchorPoint = Vector2.new(0, 0.5);
				BackgroundTransparency = 1;
				Size = UDim2.new(1, 0, 0.87, -8);
				Text = [[<font weight="900"><u>FORK</u><br/>3X</font>]];
				TextStrokeTransparency = 0.8;
				TextScaled = true;
				RichText = true;
				TextYAlignment = Enum.TextYAlignment.Bottom;
				TextColor3 = Color3.new(1, 1, 1);
				Font = Enum.Font.SourceSansBold;
				Position = UDim2.new(0.05, 0, 0.5, -4);
				ZIndex = 3;
			}, {
				AspectRatio = new('UIAspectRatioConstraint', {
					AspectRatio = 1.2;
				});
			});
			HelpIcon = new('ImageLabel', {
				AnchorPoint = Vector2.new(1, 0.5);
				BackgroundTransparency = 1;
				Position = UDim2.new(1, 0, 0.5, -4);
				Size = UDim2.new(0, 30, 0, 30);
				Image = 'rbxassetid://141911973';
				ZIndex = 3;
			});
			ManualWindowPortal = new(Roact.Portal, {
				target = self.props.Core.UI;
			}, {
				ManualWindow = (self.state.IsManualOpen or nil) and new(ToolManualWindow, {
					Text = MANUAL_CONTENT;
					ThemeColor = Color3.fromRGB(255, 176, 0);
				});
			});
		})})
end

return AboutPane