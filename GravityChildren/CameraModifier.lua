local UIS = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local RunService = game:GetService("RunService")

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

	-- Mouse behavior fix
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

	-- Gravity-aligned up vector
	function basecam.GetUpVector()
		return self.Controller.GravityUp
	end

	-- Camera roll alignment
	RunService:BindToRenderStep(
		"GravityCameraAlign",
		Enum.RenderPriority.Camera.Value + 1,
		function()
			local cam = workspace.CurrentCamera
			local up = self.Controller.GravityUp

			local look = cam.CFrame.LookVector
			local right = look:Cross(up).Unit
			local correctedLook = up:Cross(right).Unit

			cam.CFrame = CFrame.fromMatrix(
				cam.CFrame.Position,
				right,
				up,
				-correctedLook
			)
		end
	)

	return self
end

function CameraModifier:Destroy()
	self.BaseClass.UpdateMouseBehavior = self.DefaultMouseBehavior
	self.BaseClass.GetUpVector = self.DefaultGetUpVector
	RunService:UnbindFromRenderStep("GravityCameraAlign")
end

return CameraModifier
