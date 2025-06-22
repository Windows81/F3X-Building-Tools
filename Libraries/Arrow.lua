

-- Libraries

local Support = require(script.Parent:WaitForChild 'SupportLibrary')
local Signal = require(script.Parent:WaitForChild("Signal"))

-- Create class
local Arrow = {}
Arrow.__index = Arrow

local UpdateSignal = Signal.new()

function Arrow.new(Options)
	local self = setmetatable({}, Arrow)

    -- Create UI container
	local ArrowsFolder = game.Workspace.CurrentCamera:FindFirstChild("BTArrows") or Instance.new('Folder')	-- Rare time I use this method. Slow, but allows the same way of running.
	self.ArrowsFolder = ArrowsFolder
	ArrowsFolder.Name = 'BTArrows'
	ArrowsFolder.Parent = game.Workspace.CurrentCamera

	-- Create interface
	print("A")
    self:CreateArrow(Options)

    -- Return new handles
    return self
end

function Arrow:CreateArrow(Options)
	self.Arrows = {}
	
	if not self.Update then
		self.Update = Support.ScheduleRecurringTask(function() UpdateSignal:Fire() end, 1 / 30);
	end

		-- Create handle
		local ArrowModel = Instance.new("Model")
		ArrowModel.Name = "BTArrow"

        local Handle = Instance.new('Part')
        Handle.Name = "Handle"
		Handle.Shape = Enum.PartType.Cylinder
		Handle.Anchored = true
		Handle.Locked = true
		Handle.Color = Color3.new(0, 1, 0)
		Handle.Size = Vector3.new(4, 0.254, 1)
		Handle.CastShadow = false
		Handle.Parent = ArrowModel
		
        -- Create handle dot
        local ArrowTip = Handle:Clone()
		ArrowTip.Name = "Top"
		ArrowTip.Size = Vector3.new(0.505, 1.81, 0.435)
		ArrowTip.CFrame = Handle.CFrame * CFrame.new(2, 0, 0) * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(-90)) -- 1.556
		ArrowTip.Parent = ArrowModel
		
		local TipMesh = Instance.new("SpecialMesh")
		TipMesh.Parent = ArrowTip
		TipMesh.MeshType = Enum.MeshType.FileMesh
		TipMesh.MeshId = "http://www.roblox.com/asset/?id=1033714"
		TipMesh.Offset = Vector3.new(0, 0.68, 0)
		TipMesh.Scale = Vector3.new(0.25, 2.41, 0.25)
		
		ArrowModel.PrimaryPart = Handle
		ArrowModel:ScaleTo(Options.Scale)
		ArrowModel:PivotTo(Options.Object.WorldCFrame * CFrame.new(Options.Scale * 2, 0, 0))

		-- Update the arrow with any movement exerced on the attachment.
		local Update
		
		Update = UpdateSignal:Connect(function()
			if not ArrowModel then
				Update:Disconnect()
			end
		ArrowModel:PivotTo(Options.Object.WorldCFrame * CFrame.new(Options.Scale * 2, 0, 0))
		end)

        -- Save handle
       ArrowModel.Parent = self.ArrowsFolder
	   self.Arrows[Options.Object] = ArrowModel
	   print(self.Arrows)

end

function Arrow:Destroy(Object)

	-- Clean up resources
	if Object == nil or self.Arrows == nil or table.find(self.Arrows, Object) == nil then
		return
	end
	
	self.Arrows[Object]:Destroy()
	
	if #self.Arrows == 0 then
		self.Update = nil
	end

end

return Arrow