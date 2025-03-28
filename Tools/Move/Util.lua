local Tool = script.Parent.Parent.Parent

-- Libraries
local Libraries = Tool:WaitForChild("Libraries")
local Support = require(Libraries:WaitForChild("SupportLibrary"))

local function TranslatePartsRelativeToPart(BasePart, InitialPartStates, InitialModelStates)
	-- Moves the given parts in `InitialStates` to BasePart's current position, with their original offset from it

	-- Get focused part's position for offsetting
	local PivotCFrame = InitialPartStates[BasePart].CFrame

	-- Calculate offset and move each part
	for Part, InitialState in pairs(InitialPartStates) do
		local Offset = Support.ToObjectSpace(PivotCFrame, InitialState.CFrame)

		-- Move relative to the focused part by this part's offset from it
		Part.CFrame = BasePart.CFrame * Offset

	end

	-- Calculate offset and move each model
	for Model, InitialState in pairs(InitialModelStates) do
		local Offset = Support.ToObjectSpace(PivotCFrame, InitialState.Pivot)
		Model.WorldPivot = BasePart.CFrame * Offset
	end
end

local function GetIncrementMultiple(Number, Increment)

	-- Get how far the actual distance is from a multiple of our increment
	local MultipleDifference = Number % Increment

	-- Identify the closest lower and upper multiples of the increment
	local LowerMultiple = Number - MultipleDifference
	local UpperMultiple = Number - MultipleDifference + Increment

	-- Calculate to which of the two multiples we're closer
	local LowerMultipleProximity = math.abs(Number - LowerMultiple)
	local UpperMultipleProximity = math.abs(Number - UpperMultiple)

	-- Use the closest multiple of our increment as the distance moved
	if LowerMultipleProximity <= UpperMultipleProximity then
		Number = LowerMultiple
	else
		Number = UpperMultiple
	end

	return Number
end

return {
    TranslatePartsRelativeToPart = TranslatePartsRelativeToPart;
    GetIncrementMultiple = GetIncrementMultiple;
}