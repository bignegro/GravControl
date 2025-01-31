local Draw3D = {}

-- Style Guide

Draw3D.StyleGuide = {
	Point = {
		Thickness = 0.5;
		Color = Color3.new(0, 1, 0);
	},
	
	Line = {
		Thickness = 0.1;
		Color = Color3.new(1, 1, 0);
	},
	
	Ray = {
		Thickness = 0.1;
		Color = Color3.new(1, 0, 1);
	},
	
	Triangle = {
		Thickness = 0.05;
	};
	
	CFrame = {
		Thickness = 0.1;
		RightColor3 = Color3.new(1, 0, 0);
		UpColor3 = Color3.new(0, 1, 0);
		BackColor3 = Color3.new(0, 0, 1);
		PartProperties = {
			Material = Enum.Material.SmoothPlastic;
		};
	}
}

-- CONSTANTS

local WEDGE = Instance.new("WedgePart")
WEDGE.Material = Enum.Material.SmoothPlastic
WEDGE.Anchored = true
WEDGE.CanCollide = false

local PART = Instance.new("Part")
PART.Size = Vector3.new(0.1, 0.1, 0.1)
PART.Anchored = true
PART.CanCollide = false
PART.TopSurface = Enum.SurfaceType.Smooth
PART.BottomSurface = Enum.SurfaceType.Smooth
PART.Material = Enum.Material.SmoothPlastic

-- Functions

local function draw(properties, style)
	local part = PART:Clone()
	for k, v in next, properties do
		part[k] = v
	end
	if (style) then
		for k, v in next, style do
			if (k ~= "Thickness") then
				part[k] = v
			end
		end
	end
	return part
end

function Draw3D.Draw(parent, properties)
	properties.Parent = parent
	return draw(properties, nil)
end

function Draw3D.Point(parent, cf_v3)
	local thickness = Draw3D.StyleGuide.Point.Thickness
	return draw({
		Size = Vector3.new(thickness, thickness, thickness);
		CFrame = (typeof(cf_v3) == "CFrame" and cf_v3 or CFrame.new(cf_v3));
		Parent = parent;
	}, Draw3D.StyleGuide.Point)
end

function Draw3D.Line(parent, a, b)
	local thickness = Draw3D.StyleGuide.Line.Thickness
	return draw({
		CFrame = CFrame.new((a + b)/2, b);
		Size = Vector3.new(thickness, thickness, (b - a).Magnitude);
		Parent = parent;
	}, Draw3D.StyleGuide.Line)
end

function Draw3D.Ray(parent, origin, direction)
	local thickness = Draw3D.StyleGuide.Ray.Thickness
	return draw({
		CFrame = CFrame.new(origin + direction/2, origin + direction);
		Size = Vector3.new(thickness, thickness, direction.Magnitude);
		Parent = parent;
	}, Draw3D.StyleGuide.Ray)
end

function Draw3D.Triangle(parent, a, b, c)
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	
	if (abd > acd and abd > bcd) then
		c, a = a, c
	elseif (acd > bcd and acd > abd) then
		a, b = b, a
	end
	
	ab, ac, bc = b - a, c - a, c - b
	
	local right = ac:Cross(ab).Unit
	local up = bc:Cross(right).Unit
	local back = bc.Unit
	
	local height = math.abs(ab:Dot(up))
	local width1 = math.abs(ab:Dot(back))
	local width2 = math.abs(ac:Dot(back))
	
	local thickness = Draw3D.StyleGuide.Triangle.Thickness
	
	local w1 = WEDGE:Clone()
	w1.Size = Vector3.new(thickness, height, width1)
	w1.CFrame = CFrame.fromMatrix((a + b)/2, right, up, back)
	w1.Parent = parent
	
	local w2 = WEDGE:Clone()
	w2.Size = Vector3.new(thickness, height, width2)
	w2.CFrame = CFrame.fromMatrix((a + c)/2, -right, up, -back)
	w2.Parent = parent
	
	for k, v in next, Draw3D.StyleGuide.Triangle do
		if (k ~= "Thickness") then
			w1[k] = v
			w2[k] = v
		end
	end
	
	return w1, w2
end

function Draw3D.CFrame(parent, cf)
	local origin = cf.Position
	local r = cf.RightVector
	local u = cf.UpVector
	local b = -cf.LookVector
	
	local thickness = Draw3D.StyleGuide.CFrame.Thickness
	
	local right = draw({
		CFrame = CFrame.new(origin + r/2, origin + r);
		Size = Vector3.new(thickness, thickness, r.Magnitude);
		Color = Draw3D.StyleGuide.CFrame.RightColor3;
		Parent = parent;
	}, Draw3D.StyleGuide.CFrame.PartProperties)
	
	local up = draw({
		CFrame = CFrame.new(origin + u/2, origin + u);
		Size = Vector3.new(thickness, thickness, r.Magnitude);
		Color = Draw3D.StyleGuide.CFrame.UpColor3;
		Parent = parent;
	}, Draw3D.StyleGuide.CFrame.PartProperties)
	
	local back = draw({
		CFrame = CFrame.new(origin + b/2, origin + b);
		Size = Vector3.new(thickness, thickness, u.Magnitude);
		Color = Draw3D.StyleGuide.CFrame.BackColor3;
		Parent = parent;
	}, Draw3D.StyleGuide.CFrame.PartProperties)
	
	return right, up, back
end

-- Return

return Draw3D