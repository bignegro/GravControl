local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CameraModifier = {}
CameraModifier.__index = CameraModifier

function CameraModifier.new(player, controller)
	local self = setmetatable({}, CameraModifier)

	local playerModule = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")
	local cameraModule = require(playerModule:WaitForChild("CameraModule"))

	-- Force camera module to initialize
	cameraModule:ActivateCamera()

	-- THIS is the real camera instance Roblox uses
	local cam = cameraModule.activeCamera
	assert(cam, "activeCamera not found")

	self.CameraModule = cameraModule
	self.ActiveCamera = cam
	self.Controller = controller

	-- Save original Update
	self._oldUpdate = cam.Update

	-- 🔥 PATCH THE *INSTANCE* UPDATE
	function cam:Update(dt)
		-- Normal Roblox camera behavior
		self:_oldUpdate(dt)

		local camera = workspace.CurrentCamera
		local up = controller.GravityUp

		-- Skip if gravity is normal
		if up:Dot(Vector3.yAxis) > 0.999 then
			return
		end

		-- Apply gravity roll
		local cf = camera.CFrame
		local worldUp = Vector3.yAxis

		local axis = worldUp:Cross(up)
		if axis.Magnitude < 1e-4 then
			return
		end

		local angle = math.acos(math.clamp(worldUp:Dot(up), -1, 1))
		local rot = CFrame.fromAxisAngle(axis.Unit, angle)

		camera.CFrame = rot * cf
	end

	return self
end

function CameraModifier:Destroy()
	if self.ActiveCamera and self._oldUpdate then
		self.ActiveCamera.Update = self._oldUpdate
	end
end

return CameraModifier
