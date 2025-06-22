return function (creation_data, Container)
	local objects = {};
	
	for part_id, part_data in pairs( creation_data.parts ) do
		local Part;
	
		local part_type = part_data[1];
		if part_type == 1 then
			Part = Instance.new( "Part" );
		elseif part_type == 2 then
			Part = Instance.new( "TrussPart" );
		elseif part_type == 3 then
			Part = Instance.new( "WedgePart" );
		elseif part_type == 4 then
			Part = Instance.new( "CornerWedgePart" );
		elseif part_type == 5 then
			Part = Instance.new( "Part" );
			Part.Shape = "Cylinder";
		elseif part_type == 6 then
			Part = Instance.new( "Part" );
			Part.Shape = "Ball";
		elseif part_type == 7 then
			Part = Instance.new( "Seat" );
		elseif part_type == 8 then
			Part = Instance.new( "VehicleSeat" );
		elseif part_type == 9 then
			Part = Instance.new( "SpawnLocation" );
		end;
		objects[part_id] = Part;
	
		Part.Size = Vector3.new( unpack( part_data[2] ) );
		Part.CFrame = CFrame.new( unpack( part_data[3] ) );
		Part.BrickColor = BrickColor.new( part_data[4] );
		Part.Material = part_data[5];
		Part.Anchored = part_data[6];
		Part.CanCollide = part_data[7];
		Part.Reflectance = part_data[8];
		Part.Transparency = part_data[9];
		Part.TopSurface = part_data[10];
		Part.BottomSurface = part_data[11];
		Part.LeftSurface = part_data[12];
		Part.RightSurface = part_data[13];
		Part.FrontSurface = part_data[14];
		Part.BackSurface = part_data[15];
	
		Part.Parent = Container;
	
		-- Add the part ID if it's referenced somewhere else
		if creation_data.welds then
			for _, Weld in pairs( creation_data.welds ) do
				if Weld[1] == part_id or Weld[2] == part_id then
					local Tag = Instance.new('StringValue')
					Tag.Name = 'BTID'
					Tag.Value = part_id
					Tag.Parent = Part
					break
				end;
			end;
		end;
	
	end;
	
	if creation_data.welds then
		local weld_count = 0;
		for _, __ in pairs( creation_data.welds ) do
			weld_count = weld_count + 1;
		end;
		if weld_count > 0 then
			local WeldScript = Instance.new( 'Script' );
			WeldScript.Name = 'BTWelder';
			WeldScript.Source = [[-- This script creates the welds between parts imported by the Building Tools by F3X plugin.
	
	local BeforeAnchored = {};
	for _, Part in pairs(script.Parent:GetChildren()) do
	if Part:IsA 'BasePart' then
	BeforeAnchored[Part] = Part.Anchored;
	Part.Anchored = true;
	end;
	end;
	
	function _getAllDescendants( Parent )
	-- Recursively gets all the descendants of  `Parent` and returns them
	
	local descendants = {};
	
	for _, Child in pairs( Parent:GetChildren() ) do
	
	-- Add the direct descendants of `Parent`
	table.insert( descendants, Child );
	
	-- Add the descendants of each child
	for _, Subchild in pairs( _getAllDescendants( Child ) ) do
		table.insert( descendants, Subchild );
	end;
	
	end;
	
	return descendants;
	
	end;
	function findExportedPart( part_id )
	for _, Object in pairs( _getAllDescendants( script.Parent ) ) do
	if Object:IsA( 'StringValue' ) then
		if Object.Name == 'BTID' and Object.Value == part_id then
			return Object.Parent;
		end;
	end;
	end;
	end;
	
	]];
	
			for weld_id, weld_data in pairs( creation_data.welds ) do
				WeldScript.Source = WeldScript.Source .. [[
	
	( function ()
	local Part0 = findExportedPart( ']] .. weld_data[1] .. [[' );
	local Part1 = findExportedPart( ']] .. weld_data[2] .. [[' );
	if not Part0 or not Part1 then
	return;
	end;
	local Weld = Instance.new('Weld')
	Weld.Name = 'BTWeld';
	Weld.Parent = Game.JointsService;
	Weld.Archivable = false;
	Weld.Part0 = Part0;
	Weld.Part1 = Part1;
	Weld.C1 = CFrame.new( ]] .. table.concat( weld_data[3], ', ' ) .. [[ );
	end )();
	]];
			end;
	
			WeldScript.Source = WeldScript.Source .. [[
	
	for Part, Anchored in pairs(BeforeAnchored) do
	Part.Anchored = Anchored;
	end;]];
			WeldScript.Parent = Container;
		end;
	end;
	
	if creation_data.meshes then
		for mesh_id, mesh_data in pairs( creation_data.meshes ) do
	
			-- Create, place, and register the mesh
			local Mesh = Instance.new( "SpecialMesh", objects[mesh_data[1]] );
			objects[mesh_id] = Mesh;
	
			-- Set the mesh's properties
			Mesh.MeshType = mesh_data[2];
			Mesh.Scale = Vector3.new( unpack( mesh_data[3] ) );
			Mesh.MeshId = mesh_data[4];
			Mesh.TextureId = mesh_data[5];
			Mesh.VertexColor = Vector3.new( unpack( mesh_data[6] ) );
	
		end;
	end;
	
	if creation_data.textures then
		for texture_id, texture_data in pairs( creation_data.textures ) do
	
			-- Create, place, and register the texture
			local texture_class;
			if texture_data[2] == 1 then
				texture_class = 'Decal';
			elseif texture_data[2] == 2 then
				texture_class = 'Texture';
			end;
			local Texture = Instance.new( texture_class, objects[texture_data[1]] );
			objects[texture_id] = Texture;
	
			-- Set the texture's properties
			Texture.Face = texture_data[3];
			Texture.Texture = texture_data[4];
			Texture.Transparency = texture_data[5];
			if Texture:IsA( "Texture" ) then
				Texture.StudsPerTileU = texture_data[6];
				Texture.StudsPerTileV = texture_data[7];
			end;
	
		end;
	end;
	
	if creation_data.lights then
		for light_id, light_data in pairs( creation_data.lights ) do
	
			-- Create, place, and register the light
			local light_class;
			if light_data[2] == 1 then
				light_class = 'PointLight';
			elseif light_data[2] == 2 then
				light_class = 'SpotLight';
			end;
			local Light = Instance.new( light_class, objects[light_data[1]] )
			objects[light_id] = Light;
	
			-- Set the light's properties
			Light.Color = Color3.new( unpack( light_data[3] ) );
			Light.Brightness = light_data[4];
			Light.Range = light_data[5];
			Light.Shadows = light_data[6];
			if Light:IsA( 'SpotLight' ) then
				Light.Angle = light_data[7];
				Light.Face = light_data[8];
			end;
	
		end;
	end;
	
	if creation_data.decorations then
		for decoration_id, decoration_data in pairs( creation_data.decorations ) do
	
			-- Create and register the decoration
			if decoration_data[2] == 1 then
				local Smoke = Instance.new('Smoke')
				Smoke.Color = Color3.new( unpack( decoration_data[3] ) )
				Smoke.Opacity = decoration_data[4];
				Smoke.RiseVelocity = decoration_data[5];
				Smoke.Size = decoration_data[6]
				Smoke.Parent = objects[decoration_data[1]]
				objects[decoration_id] = Smoke
	
			elseif decoration_data[2] == 2 then
				local Fire = Instance.new('Fire')
				Fire.Color = Color3.new( unpack( decoration_data[3] ) );
				Fire.SecondaryColor = Color3.new( unpack( decoration_data[4] ) );
				Fire.Heat = decoration_data[5];
				Fire.Size = decoration_data[6];
				Fire.Parent = objects[decoration_data[1]];
				objects[decoration_id] = Fire;
	
			elseif decoration_data[2] == 3 then
				local Sparkles = Instance.new('Sparkles')
				Sparkles.SparkleColor = Color3.new( unpack( decoration_data[3] ) );
				Sparkles.Parent = objects[decoration_data[1]];
				objects[decoration_id] = Sparkles;
			end;
	
		end;
	end;
end