local physProperties = PhysicalProperties.new(0.7, 0, 0, 1, 100)
local SPHERE = Instance.new("Part")
SPHERE.Name = "Sphere"
SPHERE.Shape = Enum.PartType.Ball
SPHERE.Size = Vector3.new(2, 2, 2)
SPHERE.Material = Enum.Material.SmoothPlastic
SPHERE.Transparency = 1
SPHERE.Anchored = false
SPHERE.Massless = true
SPHERE.CustomPhysicalProperties = physProperties

local FLOOR = Instance.new("Part")
FLOOR.Name = "Floor"
FLOOR.Transparency = 1
FLOOR.Size = Vector3.new(2, 1, 1)
FLOOR.CanCollide = false
FLOOR.CanQuery = true
FLOOR.CanTouch = true
FLOOR.Anchored = false
FLOOR.Massless = true
local VFORCE = Instance.new("VectorForce")
VFORCE.Name = "VectorForce"
VFORCE.Color = BrickColor.new("Bright Blue")
VFORCE.Visible = false
VFORCE.Enabled = true
VFORCE.ApplyAtCenterOfMass = true
VFORCE.Force = Vector3.new(0, 0, 0)
VFORCE.RelativeTo = Enum.ActuatorRelativeTo.World

local BGYRO = Instance.new("BodyGyro")
BGYRO.Name = "BodyGyro"
BGYRO.D = 500
BGYRO.MaxTorque = Vector3.new(100000, 100000, 100000)
BGYRO.P = 25000

local function initObjects(self)
	local hrp = self.HRP
	local humanoid = self.Humanoid
	
	local sphere = SPHERE:Clone()
	sphere.Parent = self.Character
	
	local floor = FLOOR:Clone()
	floor.Parent = self.Character
	
	local isR15 = (humanoid.RigType == Enum.HumanoidRigType.R15)
	local height = isR15 and (humanoid.HipHeight + 0.05) or 2
	
	local weld = Instance.new("Weld")
	weld.C0 = CFrame.new(0, -height, 0.1)
	weld.Part0 = hrp
	weld.Part1 = sphere
	weld.Parent = sphere
	
	local weld2 = Instance.new("Weld")
	weld2.C0 = CFrame.new(0, -(height + 1.5), 0)
	weld2.Part0 = hrp
	weld2.Part1 = floor
	weld2.Parent = floor
	
	local gyro = BGYRO:Clone()
	gyro.CFrame = hrp.CFrame
	gyro.Parent = hrp
	
	local vForce = VFORCE:Clone()
	vForce.Attachment0 = isR15 and hrp:WaitForChild("RootRigAttachment") or hrp:WaitForChild("RootAttachment")
	vForce.Parent = hrp
	
	return sphere, gyro, vForce, floor
end

return initObjects