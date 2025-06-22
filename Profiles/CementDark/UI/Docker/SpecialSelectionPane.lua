local Root = script:FindFirstAncestorWhichIsA('Tool')
local Vendor = Root:WaitForChild('Vendor')
local Libraries = Root:WaitForChild('Libraries')

-- Libraries
local Roact = require(Vendor:WaitForChild('Roact'))
local Maid = require(Libraries:WaitForChild('Maid'))

-- Roact
local new = Roact.createElement
local SelectionButton = require(script.Parent:WaitForChild('SelectionButton'))

-- Create component
local SelectionPane = Roact.PureComponent:extend(script.Name)

function SelectionPane:init()
    self.Maid = Maid.new()
    self.PaneSize, self.SetPaneSize = Roact.createBinding(UDim2.new())

    self:UpdateHistoryState()
    self.Maid.TrackHistory = self.props.Core.History.Changed:Connect(function ()
        self:UpdateHistoryState()
    end)

    self:UpdateSelectionState()
    self.Maid.TrackSelection = self.props.Core.Selection.Changed:Connect(function ()
        self:UpdateSelectionState()
    end)
	
	self:UpdateMultiselectState()
	self.Maid.TrackMultiselect = self.props.Core.Selection.MultiselectToggle:Connect(function ()
		self:UpdateMultiselectState()
	end)

    self:UpdateExplorerState()
    self.Maid.TrackExplorer = self.props.Core.ExplorerVisibilityChanged:Connect(function ()
        self:UpdateExplorerState()
    end)
end

function SelectionPane:UpdateHistoryState()
    self:setState({
        CanUndo = (self.props.Core.History.Index > 0);
        CanRedo = (self.props.Core.History.Index ~= #self.props.Core.History.Stack);
    })
end

function SelectionPane:UpdateSelectionState()
    self:setState({
        IsSelectionEmpty = (#self.props.Core.Selection.Items == 0);
    })
end

function SelectionPane:UpdateMultiselectState()
	self:setState({
		IsMultiselecting = (self.props.Core.Selection.Multiselecting);
	})
end

function SelectionPane:UpdateExplorerState()
    self:setState({
        IsExplorerOpen = self.props.Core.ExplorerVisible;
    })
end

function SelectionPane:willUnmount()
    self.Maid:Destroy()
end

function SelectionPane:UpdateSelectAllState()
	self:setState({
		IsSelectAllOpen = self.props.Core.SelectAllVisible;
	})
end

function SelectionPane:render()
	--if IconSpace <= TabSpace then
		return new('Frame', {
	        BackgroundTransparency = 0.5;
	        BackgroundColor3 = Color3.fromRGB(0, 0, 0);
			BorderSizePixel = 0;
			Size = UDim2.fromScale(1, 0);
	        LayoutOrder = self.props.LayoutOrder;
			AutomaticSize = Enum.AutomaticSize.Y,
	    }, {
	        Corners = new('UICorner', {
	            CornerRadius = UDim.new(0, 8);
	        });
	        SizeConstraint = new('UISizeConstraint', {
	            MinSize = Vector2.new(70, 0);
	        });
	        Layout = new('UIGridLayout', {
	            CellPadding = UDim2.new(0, 0, 0, 0);
	            CellSize = UDim2.new(0, 55, 0, 55);
	            FillDirection = Enum.FillDirection.Horizontal;
	            FillDirectionMaxCells = 0;
	            HorizontalAlignment = Enum.HorizontalAlignment.Left;
	            VerticalAlignment = Enum.VerticalAlignment.Top;
	            SortOrder = Enum.SortOrder.LayoutOrder;
	            StartCorner = Enum.StartCorner.TopLeft;
	            --[Roact.Ref] = function (rbx)
	            --    if rbx then
	            --        self.SetPaneSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
	            --    end
	            --end;
	            --[Roact.Change.AbsoluteContentSize] = function (rbx)
	            --    self.SetPaneSize(UDim2.fromOffset(rbx.AbsoluteContentSize.X, rbx.AbsoluteContentSize.Y))
	            --end;
	        });

	        MultiSelect = new(SelectionButton, {
				LayoutOrder = 0;
				IconAssetId = 'rbxassetid://16124331566';
				IsActive = self.state.IsMultiselecting;
				OnActivated = self.props.Core.ChangeMultiselectingMode;
				TooltipText = '<b>MULTISELECT STATUS</b><br />Shift';
			});
		})
end

return SelectionPane