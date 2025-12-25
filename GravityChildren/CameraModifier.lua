local UIS = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CameraModifier = {}
CameraModifier.__index = CameraModifier

function CameraModifier.new(player, controller)
	local self = setmetatable({}, CameraModifier)

	local playerModule = player.PlayerScripts:WaitForChild("PlayerModule")
	local cameraModule = playerModule:WaitForChild("CameraModule")
	local basecam = require(cameraModule:WaitForChild("BaseCamera"))

	self.Controller = controller
	self.BaseCamera = basecam

	self._oldGetUpVector = basecam.GetUpVector
	self._oldUpdateMouseBehavior = basecam.UpdateMouseBehavior

	-- 🔒 ALWAYS LOCK MOUSE (required for free look)
	function basecam.UpdateMouseBehavior(this)
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	end

	-- 🌍 THIS IS THE KEY: gravity-relative camera
	function basecam.GetUpVector()
		return controller.GravityUp
	end

	return self
end

function CameraModifier:Destroy()
	self.BaseCamera.GetUpVector = self._oldGetUpVector
	self.BaseCamera.UpdateMouseBehavior = self._oldUpdateMouseBehavior
end

return CameraModifier
