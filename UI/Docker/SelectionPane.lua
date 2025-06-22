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
			BackgroundColor3 = Color3.new(0.0666667, 0.0705882, 0.0862745);
			BorderSizePixel = 0;
			Size = UDim2.fromScale(1, 0);
	        LayoutOrder = self.props.LayoutOrder;
			AutomaticSize = Enum.AutomaticSize.Y,
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
	        Layout = new('UIGridLayout', {
	            CellPadding = UDim2.new(0, 0, 0, 0);
	            CellSize = UDim2.new(0, 35, 0, 35);
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

	        UndoButton = new(SelectionButton, {
	            LayoutOrder = 0;
	            IconAssetId = 'rbxassetid://141741408';
	            IsActive = self.state.CanUndo;
	            OnActivated = self.props.Core.History.Undo;
	            TooltipText = '<b>UNDO</b><br />Shift-Z';
	        });
	        RedoButton = new(SelectionButton, {
	            LayoutOrder = 1;
	            IconAssetId = 'rbxassetid://141741327';
	            IsActive = self.state.CanRedo;
	            OnActivated = self.props.Core.History.Redo;
	            TooltipText = '<b>REDO</b><br />Shift-Y';
	        });
	        ExportButton = new(SelectionButton, {
	            LayoutOrder = 2;
	            IconAssetId = 'rbxassetid://141741337';
	            IsActive = not self.state.IsSelectionEmpty;
	            OnActivated = self.props.Core.ExportSelection;
	            TooltipText = '<b>EXPORT</b><br />Shift-P';
	        });
			DeleteButton = new(SelectionButton, {
				LayoutOrder = 3;
				IconAssetId = 'rbxassetid://141896298';
				IsActive = not self.state.IsSelectionEmpty;
				OnActivated = self.props.Core.DeleteSelection;
				TooltipText = '<b>DELETE</b><br />Shift-X';
			});
	        CloneButton = new(SelectionButton, {
	            LayoutOrder = 4;
	            IconAssetId = 'rbxassetid://142073926';
	            IsActive = not self.state.IsSelectionEmpty;
	            OnActivated = self.props.Core.CloneSelection;
	            TooltipText = '<b>CLONE</b><br />Shift-C';
	        });
	        ExplorerButton = new(SelectionButton, {
	            LayoutOrder = 5;
	            IconAssetId = 'rbxassetid://2326621485';
	            IsActive = self.state.IsExplorerOpen;
	            OnActivated = self.props.Core.ToggleExplorer;
	            TooltipText = '<b>EXPLORER</b><br />Shift-H';
			});
			GroupSelectionButton = new(SelectionButton, {
				LayoutOrder = 6;
				IconAssetId = 'rbxassetid://9421312861';
				IsActive = not self.state.IsSelectionEmpty;
				OnActivated = self.props.Core.Support.Call(self.props.Core.GroupSelection, "Model");
				TooltipText = '<b>GROUP SELECTION</b><br />Shift-G';
				Size = UDim2.new(0.75, 0, 0.75, 0);
				Position = UDim2.new(0.15, 0, 0.125, 0);
			});
			SelectSiblingsButton = new(SelectionButton, {
				LayoutOrder = 7;
				IconAssetId = 'rbxassetid://9421207522';
				IsActive = not self.state.IsSelectionEmpty;
				OnActivated = self.props.Core.Support.Call(self.props.Core.Targeting.SelectSiblings, false, false);
				TooltipText = '<b>SELECT SIBLINGS</b><br />Shift-[';
				Size = UDim2.new(0.75, 0, 0.75, 0);
				Position = UDim2.new(0.15, 0, 0.125, 0);
			});
			SelectAllButton = new(SelectionButton, {
				LayoutOrder = 8;
				IconAssetId = 'rbxassetid://9421205777';
				IsActive = true;
				OnActivated = self.props.Core.SelectAll;
				TooltipText = '<b>SELECT ALL</b><br />Shift-]';
				Size = UDim2.new(0.75, 0, 0.75, 0);
				Position = UDim2.new(0.15, 0, 0.125, 0);
			});
			UnGroupSelectionButton = new(SelectionButton, {
				LayoutOrder = 9;
				IconAssetId = 'rbxassetid://9421424096';
				IsActive = not self.state.IsSelectionEmpty;
				OnActivated = self.props.Core.UngroupSelection;
				TooltipText = '<b>UNGROUP SELECTION</b><br />Shift-U';
				Size = UDim2.new(0.75, 0, 0.75, 0);
				Position = UDim2.new(0.15, 0, 0.125, 0);
			});
			DataButton = new(SelectionButton, {
				LayoutOrder = 10;
				IconAssetId = "rbxassetid://12392896984";
				IsActive = self.state.IsSaveLoadOpen;
				OnActivated = self.props.Core.ToggleSaveLoad;
				TooltipText = '<b>SAVE/LOAD</b><br />Shift-L';
				Size = UDim2.new(0.7, 0, 0.7, 0);
				Position = UDim2.new(0.175, 0, 0.15, 0);
			});
		})
end

return SelectionPane