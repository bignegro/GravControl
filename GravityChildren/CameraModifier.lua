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

	self.DefaultUpdate = basecam.Update
	self.DefaultGetUpVector = basecam.GetUpVector
	self.DefaultMouseBehavior = basecam.UpdateMouseBehavior

	-- Mouse behavior (do NOT force shiftlock)
	function basecam.UpdateMouseBehavior(this)
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end

	-- Gravity-relative up
	function basecam.GetUpVector()
		return controller.GravityUp
	end

	-- 🔥 THE IMPORTANT PART: rotate yaw around GravityUp
	function basecam.Update(this, dt)
		-- Let Roblox do its normal camera math
		self.DefaultUpdate(this, dt)

		local cam = workspace.CurrentCamera
		local up = controller.GravityUp

		-- Rotate camera yaw into gravity space
		local look = cam.CFrame.LookVector
		local flatLook = look - look:Dot(up) * up

		if flatLook.Magnitude > 0.001 then
			flatLook = flatLook.Unit
			local right = flatLook:Cross(up).Unit
			cam.CFrame = CFrame.fromMatrix(
				cam.CFrame.Position,
				right,
				up,
				-flatLook
			)
		end
	end

	return self
end

function CameraModifier:Destroy()
	self.BaseClass.Update = self.DefaultUpdate
	self.BaseClass.GetUpVector = self.DefaultGetUpVector
	self.BaseClass.UpdateMouseBehavior = self.DefaultMouseBehavior
end

return CameraModifier
