--[[

GravityController
Wall-walk / ceiling-walk controller
FIXED jump + FIXED camera + FIXED raycast ignores

]]

--// Constants
local ZERO = Vector3.zero
local UNIT_Y = Vector3.yAxis
local IDENTITYCF = CFrame.identity

local WALKF = 200 / 3
local TRANSITION = 0.15
local FLOOR_RAY = 4

--// Services
local UIS = game:GetService("UserInputService")
local RUNSERVICE = game:GetService("RunService")

--// External modules
local InitObjects =
	loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/bignegro/GravControl/refs/heads/main/GravityChildren/InitObjects.lua"
	))()

local CameraModifier =
	loadstring(game:HttpGet(
		"https://raw.githubusercontent.com/bignegro/GravControl/refs/heads/main/GravityChildren/CameraModifier.lua"
	))()

--// Class
local GravityController = {}
GravityController.__index = GravityController

--////////////////////////////////////////////////////////////
-- Utilities
--////////////////////////////////////////////////////////////

local function getRotationBetween(u, v, axis)
	local dot = u:Dot(v)
	if dot < -0.99999 then
		return CFrame.fromAxisAngle(axis, math.pi)
	end
	local cross = u:Cross(v)
	return CFrame.new(0, 0, 0, cross.X, cross.Y, cross.Z, 1 + dot)
end

local function getMass(parts)
	local m = 0
	for _, p in ipairs(parts) do
		if p:IsA("BasePart") then
			m += p:GetMass()
		end
	end
	return m
end

local function getPointVelocity(part, point)
	local pcf = part.CFrame
	local lp = pcf:PointToObjectSpace(point)
	local av = pcf:VectorToObjectSpace(part.RotVelocity)
	return part.Velocity + pcf:VectorToWorldSpace(av:Cross(lp))
end

--////////////////////////////////////////////////////////////
-- Constructor
--////////////////////////////////////////////////////////////

function GravityController.new(player)
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local self = setmetatable({}, GravityController)

	-- Player
	self.Player = player
	self.Character = player.Character or player.CharacterAdded:Wait()
	self.Humanoid = self.Character:WaitForChild("Humanoid")
	self.HRP = self.Character:WaitForChild("HumanoidRootPart")

	-- PlayerModule
	local pm = require(player.PlayerScripts:WaitForChild("PlayerModule"))
	self.Controls = pm:GetControls()
	self.Camera = pm:GetCameras()

	-- Camera modifier
	self.CameraModifier = CameraModifier.new(player)

	-- Physics objects
	local collider, gyro, vForce, floor = InitObjects(self)
	floor.Touched:Connect(function() end)

	self.Collider = collider
	self.Gyro = gyro
	self.VForce = vForce
	self.Floor = floor

	-- State
	self.GravityUp = UNIT_Y
	self.CharacterMass = getMass(self.Character:GetDescendants())

	self.Humanoid.PlatformStand = true

	self.Character.AncestryChanged:Connect(function()
		self.CharacterMass = getMass(self.Character:GetDescendants())
	end)

	-- Camera up override
	function self.Camera.GetUpVector()
		return self.GravityUp
	end

	-- Events
	self.JumpCon = UIS.JumpRequest:Connect(function()
		self:OnJump()
	end)

	self.DeathCon = self.Humanoid.Died:Connect(function()
		self:Destroy()
	end)

	self.SeatCon = self.Humanoid.Seated:Connect(function(seated)
		if seated then
			self:Destroy()
		end
	end)

	RUNSERVICE:BindToRenderStep(
		"GravityStep",
		Enum.RenderPriority.Input.Value + 1,
		function(dt)
			self:Step(dt)
		end
	)

	return self
end

--////////////////////////////////////////////////////////////
-- Destroy
--////////////////////////////////////////////////////////////

function GravityController:Destroy()
	if self.JumpCon then self.JumpCon:Disconnect() end
	if self.DeathCon then self.DeathCon:Disconnect() end
	if self.SeatCon then self.SeatCon:Disconnect() end

	RUNSERVICE:UnbindFromRenderStep("GravityStep")

	self.CameraModifier:Destroy()
	self.Collider:Destroy()
	self.Gyro:Destroy()
	self.VForce:Destroy()

	self.Humanoid.PlatformStand = false
	self.GravityUp = UNIT_Y
end

--////////////////////////////////////////////////////////////
-- Gravity (wall walking)
--////////////////////////////////////////////////////////////

function GravityController:GetGravityUp(oldUp)
	local ray = Ray.new(
		self.Collider.Position,
		-oldUp * FLOOR_RAY
	)

	local hit, _, normal =
		workspace:FindPartOnRayWithIgnoreList(ray, { self.Character })

	if hit and hit:IsA("BasePart") then
		return normal
	end

	return oldUp
end

--////////////////////////////////////////////////////////////
-- Grounding
--////////////////////////////////////////////////////////////

function GravityController:IsGrounded()
	for _, p in ipairs(self.Floor:GetTouchingParts()) do
		if not p:IsDescendantOf(self.Character) then
			return true
		end
	end
	return false
end

function GravityController:GetFloorVelocity()
	local ray = Ray.new(
		self.Collider.Position,
		-self.GravityUp * FLOOR_RAY
	)

	local hit =
		workspace:FindPartOnRayWithIgnoreList(ray, { self.Character })

	if hit and hit:IsA("BasePart") then
		return getPointVelocity(hit, self.HRP.Position)
	end

	return ZERO
end

--////////////////////////////////////////////////////////////
-- Jump (FIXED — no velocity stacking)
--////////////////////////////////////////////////////////////

function GravityController:OnJump()
	if not self:IsGrounded() then return end

	local vel = self.HRP.Velocity
	local lateral = vel - vel:Dot(self.GravityUp) * self.GravityUp

	self.HRP.Velocity =
		lateral +
		self.GravityUp * self.Humanoid.JumpPower
end

--////////////////////////////////////////////////////////////
-- Main step
--////////////////////////////////////////////////////////////

function GravityController:Step(dt)
	-- Gravity smoothing
	local oldUp = self.GravityUp
	local targetUp = self:GetGravityUp(oldUp).Unit

	local rot =
		getRotationBetween(
			oldUp,
			targetUp,
			workspace.CurrentCamera.CFrame.RightVector
		)

	self.GravityUp =
		(IDENTITYCF:Lerp(rot, TRANSITION)) * oldUp

	-- Camera-relative movement
	local camCF = workspace.CurrentCamera.CFrame
	local fDot = camCF.LookVector:Dot(self.GravityUp)

	local camForward =
		math.abs(fDot) > 0.5
		and -math.sign(fDot) * camCF.UpVector
		or camCF.LookVector

	local left = camForward:Cross(-self.GravityUp).Unit
	local forward = -left:Cross(self.GravityUp).Unit

	local move = self.Controls:GetMoveVector()
	local worldMove = forward * move.Z - left * move.X
	if worldMove.Magnitude > 1 then
		worldMove = worldMove.Unit
	end

	-- Camera-driven yaw (mouse look FIX)
	local camLook = camCF.LookVector
	local flatLook =
		camLook - camLook:Dot(self.GravityUp) * self.GravityUp

	if flatLook.Magnitude > 0 then
		flatLook = flatLook.Unit
	else
		flatLook = self.HRP.CFrame.LookVector
	end

	local right = flatLook:Cross(self.GravityUp).Unit
	local charCF = CFrame.fromMatrix(ZERO, right, self.GravityUp, -flatLook)

	-- Forces
	local gForce =
		workspace.Gravity * self.CharacterMass * (UNIT_Y - self.GravityUp)

	local vel = self.HRP.Velocity
	local gVel = vel:Dot(self.GravityUp) * self.GravityUp
	local hVel = vel - gVel

	local targetVel = self.Humanoid.WalkSpeed * worldMove
	local floorVel = self:GetFloorVelocity()

	local delta = targetVel - hVel + floorVel
	local mag = math.min(10000, WALKF * self.CharacterMass * delta.Magnitude)
	local walkForce = mag > 0 and delta.Unit * mag or ZERO

	-- Apply
	self.VForce.Force = walkForce + gForce
	self.Gyro.CFrame = charCF
end

return GravityController
