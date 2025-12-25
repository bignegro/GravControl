local UIS = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CameraModifier = {}
CameraModifier.__index = CameraModifier

function CameraModifier.new(player, controller)
	local self = setmetatable({}, CameraModifier)

	local playerModule = player.PlayerScripts:WaitForChild("PlayerModule")
	local cameraModule = require(playerModule:WaitForChild("CameraModule"))

	-- Get the ACTIVE camera instance (this is the real one)
	local cam = cameraModule:GetCamera()
	assert(cam, "Failed to get active camera")

	self.Camera = cam
	self.Controller = controller

	-- Store originals
	self._oldGetUpVector = cam.GetUpVector
	self._oldUpdateMouseBehavior = cam.UpdateMouseBehavior

	-- 🔒 Lock mouse so camera actually turns
	function cam:UpdateMouseBehavior()
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	end

	-- 🌍 Gravity-relative yaw axis
	function cam:GetUpVector()
		return controller.GravityUp
	end

	return self
end

function CameraModifier:Destroy()
	if self.Camera then
		self.Camera.GetUpVector = self._oldGetUpVector
		self.Camera.UpdateMouseBehavior = self._oldUpdateMouseBehavior
	end
end

return CameraModifier
