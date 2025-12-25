local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local CameraModifier = {}
CameraModifier.__index = CameraModifier

function CameraModifier.new(player, controller)
	local self = setmetatable({}, CameraModifier)

	local playerModule = player.PlayerScripts:WaitForChild("PlayerModule")
	local cameraModule = playerModule:WaitForChild("CameraModule")
	local BaseCamera = require(cameraModule:WaitForChild("BaseCamera"))

	self.Controller = controller
	self.BaseCamera = BaseCamera

	-- Save original Update
	self._oldUpdate = BaseCamera.Update

	-- 🔥 PATCH THE CAMERA UPDATE
	function BaseCamera:Update(dt)
		-- Let Roblox compute camera normally (yaw/pitch/zoom)
		self:_oldUpdate(dt)

		local cam = workspace.CurrentCamera
		local up = controller.GravityUp

		-- If gravity is normal, do nothing
		if up:Dot(Vector3.yAxis) > 0.999 then
			return
		end

		-- Rotate camera so gravity becomes "up"
		local cf = cam.CFrame

		local worldUp = Vector3.yAxis
		local axis = worldUp:Cross(up)
		if axis.Magnitude < 1e-4 then
			return
		end

		local angle = math.acos(math.clamp(worldUp:Dot(up), -1, 1))
		local rot = CFrame.fromAxisAngle(axis.Unit, angle)

		cam.CFrame = rot * cf
	end

	return self
end

function CameraModifier:Destroy()
	-- Restore original camera behavior
	if self.BaseCamera and self._oldUpdate then
		self.BaseCamera.Update = self._oldUpdate
	end
end

return CameraModifier
