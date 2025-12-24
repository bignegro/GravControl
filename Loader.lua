-- Thanks to EmilyBendsSpace for the new get normal function!
-- https://devforum.roblox.com/t/example-source-smooth-wall-walking-gravity-controller-from-club-raven/440229?u=egomoose

-- Made by someone else credits to them 
-- Edited by slayerfortt to be used as an exploit script in games
local PLAYERS = game:GetService("Players")
local LP = PLAYERS.LocalPlayer

local GravityController = loadstring(game:HttpGet("https://raw.githubusercontent.com/bignegro/GravControl/refs/heads/main/GravityController.lua"))()
local Controller = GravityController.new(PLAYERS.LocalPlayer)

local DrawClass = loadstring(game:HttpGet("https://raw.githubusercontent.com/bignegro/GravControl/refs/heads/main/DrawClass.lua",true))().new(Controller.Character)

local PI2 = math.pi*2
local ZERO = Vector3.new(0, 0, 0)

local LOWER_RADIUS_OFFSET = 3 
local NUM_DOWN_RAYS = 24
local ODD_DOWN_RAY_START_RADIUS = 3	
local EVEN_DOWN_RAY_START_RADIUS = 2
local ODD_DOWN_RAY_END_RADIUS = 1.66666
local EVEN_DOWN_RAY_END_RADIUS = 1

local NUM_FEELER_RAYS = 9
local FEELER_LENGTH = 2
local FEELER_START_OFFSET = 2
local FEELER_RADIUS = 3.5
local FEELER_APEX_OFFSET = 1
local FEELER_WEIGHTING = 8

function GetGravityUp(self, oldGravityUp)
	local hrpCF = self.HRP.CFrame
	local isR15 = (self.Humanoid.RigType == Enum.HumanoidRigType.R15)

	local origin = isR15 and hrpCF.Position or hrpCF.Position + 0.35 * oldGravityUp
	local radialVector =
		math.abs(hrpCF.LookVector:Dot(oldGravityUp)) < 0.999
		and hrpCF.LookVector:Cross(oldGravityUp)
		or hrpCF.RightVector:Cross(oldGravityUp)

	local centerRayLength = 25
	local centerRay = Ray.new(origin, -centerRayLength * oldGravityUp)

	local centerHit, _, centerHitNormal =
		workspace:FindPartOnRayWithIgnoreList(centerRay, { LP.Character or workspace })

	local mainDownNormal = ZERO
	if centerHit then
		mainDownNormal = centerHitNormal
	end

	local downRaySum = ZERO
	local downHitCount = 0

	for i = 1, NUM_DOWN_RAYS do
		local dtheta = PI2 * ((i - 1) / NUM_DOWN_RAYS)
		local angleWeight = 0.25 + 0.75 * math.abs(math.cos(dtheta))
		local isEvenRay = (i % 2 == 0)

		local startRadius = isEvenRay and EVEN_DOWN_RAY_START_RADIUS or ODD_DOWN_RAY_START_RADIUS
		local endRadius = isEvenRay and EVEN_DOWN_RAY_END_RADIUS or ODD_DOWN_RAY_END_RADIUS

		local offset = CFrame.fromAxisAngle(oldGravityUp, dtheta) * radialVector
		local dir = (LOWER_RADIUS_OFFSET * -oldGravityUp + (endRadius - startRadius) * offset).Unit

		local ray = Ray.new(
			origin + startRadius * offset,
			centerRayLength * dir
		)

		local hit, _, hitNormal =
			workspace:FindPartOnRayWithIgnoreList(ray, { LP.Character or workspace })

		if hit then
			downRaySum += angleWeight * hitNormal
			downHitCount += 1
		end
	end

	local feelerNormalSum = ZERO
	local feelerHitCount = 0

	for i = 1, NUM_FEELER_RAYS do
		local dtheta = PI2 * ((i - 1) / NUM_FEELER_RAYS)
		local angleWeight = 0.25 + 0.75 * math.abs(math.cos(dtheta))
		local offset = CFrame.fromAxisAngle(oldGravityUp, dtheta) * radialVector

		local dir = (FEELER_RADIUS * offset + LOWER_RADIUS_OFFSET * -oldGravityUp).Unit
		local feelerOrigin = origin + FEELER_APEX_OFFSET * oldGravityUp + FEELER_START_OFFSET * dir

		local ray = Ray.new(feelerOrigin, FEELER_LENGTH * dir)

		local hit, _, hitNormal =
			workspace:FindPartOnRayWithIgnoreList(ray, { LP.Character or workspace })

		if hit then
			feelerNormalSum += FEELER_WEIGHTING * angleWeight * hitNormal
			feelerHitCount += 1
		end
	end

	if (downHitCount + feelerHitCount) > 0 then
		local normalSum = mainDownNormal + downRaySum + feelerNormalSum
		if normalSum.Magnitude > 0 then
			return normalSum.Unit
		end
	end

	return oldGravityUp
end


Controller.GetGravityUp = GetGravityUp
