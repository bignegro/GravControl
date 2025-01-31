local module = {}

-- Style Guide

module.StyleGuide = {
	Point = {
		BorderSizePixel = 0;
		Size = UDim2.new(0, 4, 0, 4);
		BorderColor3 = Color3.new(0, 0, 0);
		BackgroundColor3 = Color3.new(0, 1, 0);
	},
	
	Line = {
		Thickness = 1;
		BorderSizePixel = 0;
		BorderColor3 = Color3.new(0, 0, 0);
		BackgroundColor3 = Color3.new(0, 1, 0);
	},
	
	Ray = {
		Thickness = 1;
		BorderSizePixel = 0;
		BorderColor3 = Color3.new(0, 0, 0);
		BackgroundColor3 = Color3.new(0, 1, 0);
	},
	
	Triangle = {
		ImageTransparency = 0;
		ImageColor3 = Color3.new(0, 1, 0);
	}
}

-- CONSTANTS

local HALF = Vector2.new(0.5, 0.5)

local RIGHT = "rbxassetid://2798177521"
local LEFT = "rbxassetid://2798177955"

local IMG = Instance.new("ImageLabel")
IMG.BackgroundTransparency = 1
IMG.AnchorPoint = HALF
IMG.BorderSizePixel = 0

local FRAME = Instance.new("Frame")
FRAME.BorderSizePixel = 0
FRAME.Size = UDim2.new(0, 0, 0, 0)
FRAME.BackgroundColor3 = Color3.new(1, 1, 1)

-- Functions

function draw(properties, style)
	local frame = FRAME:Clone()
	for k, v in next, properties do
		frame[k] = v
	end
	if (style) then
		for k, v in next, style do
			if (k ~= "Thickness") then
				frame[k] = v
			end
		end
	end
	return frame
end

function module.Draw(parent, properties)
	properties.Parent = parent
	return draw(properties, nil)
end

function module.Point(parent, v2)
	return draw({
		AnchorPoint = HALF;
		Position = UDim2.new(0, v2.x, 0, v2.y);
		Parent = parent;
	}, module.StyleGuide.Point)
end

function module.Line(parent, a, b)
	local v = (b - a)
	local m = (a + b)/2
	
	return draw({
		AnchorPoint = HALF;
		Position = UDim2.new(0, m.x, 0, m.y);
		Size = UDim2.new(0, module.StyleGuide.Line.Thickness, 0, v.magnitude);
		Rotation = math.deg(math.atan2(v.y, v.x)) - 90;
		BackgroundColor3 = Color3.new(1, 1, 0);
		Parent = parent;
	}, module.StyleGuide.Line)
end

function module.Ray(parent, origin, direction)
	local a, b = origin, origin + direction
	local v = (b - a)
	local m = (a + b)/2
	
	return draw({
		AnchorPoint = HALF;
		Position = UDim2.new(0, m.x, 0, m.y);
		Size = UDim2.new(0, module.StyleGuide.Ray.Thickness, 0, v.magnitude);
		Rotation = math.deg(math.atan2(v.y, v.x)) - 90;
		Parent = parent;
	}, module.StyleGuide.Ray)
end

function module.Triangle(parent, a, b, c)
	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)
	
	if (abd > acd and abd > bcd) then
		c, a = a, c
	elseif (acd > bcd and acd > abd) then
		a, b = b, a
	end
	
	ab, ac, bc = b - a, c - a, c - b
	
	local unit = bc.unit
	local height = unit:Cross(ab)
	local flip = (height >= 0)
	local theta = math.deg(math.atan2(unit.y, unit.x)) + (flip and 0 or 180)
	
	local m1 = (a + b)/2
	local m2 = (a + c)/2
	
	local w1 = IMG:Clone()
	w1.Image = flip and RIGHT or LEFT
	w1.AnchorPoint = HALF
	w1.Size = UDim2.new(0, math.abs(unit:Dot(ab)), 0, height)
	w1.Position = UDim2.new(0, m1.x, 0, m1.y)
	w1.Rotation = theta
	w1.Parent = parent
	
	local w2 = IMG:Clone()
	w2.Image = flip and LEFT or RIGHT
	w2.AnchorPoint = HALF
	w2.Size = UDim2.new(0, math.abs(unit:Dot(ac)), 0, height)
	w2.Position = UDim2.new(0, m2.x, 0, m2.y)
	w2.Rotation = theta
	w2.Parent = parent
	
	for k, v in next, module.StyleGuide.Triangle do
		w1[k] = v
		w2[k] = v
	end
	
	return w1, w2
end

-- Return

return module