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
	self.BaseClass = basecam
	self.DefaultMouseBehavior = basecam.UpdateMouseBehavior
	self.DefaultGetUpVector = basecam.GetUpVector

	-- Mouse behavior (do NOT touch yaw)
	function basecam.UpdateMouseBehavior(this)
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative

		if this.inFirstPerson or this.inMouseLockedMode then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		elseif this.isRightMouseDown or this.isMiddleMouseDown then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		else
			UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	end

	-- 🔥 THIS IS THE KEY
	function basecam.GetUpVector()
		return controller.GravityUp
	end

	return self
end

function CameraModifier:Destroy()
	self.BaseClass.UpdateMouseBehavior = self.DefaultMouseBehavior
	self.BaseClass.GetUpVector = self.DefaultGetUpVector
end

return CameraModifier
