

if not plugin then
	require(script.Parent);
	script.Parent.Parent:WaitForChild("Options").AncestryChanged:Connect(function(parent)
		if parent ~= nil then
			return;
		end;
		script.Parent.Parent:Destroy();
	end)
end