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
	Enum.RenderPriority.Camera.Value + 5,
	function()
		local cam = workspace.CurrentCamera
		local up = self.Controller.GravityUp

		-- Rotation that maps world-up → gravity-up
		local worldUp = Vector3.yAxis
		local axis = worldUp:Cross(up)
		local dot = worldUp:Dot(up)

		if axis.Magnitude < 1e-4 then
			return -- already aligned
		end

		local angle = math.acos(math.clamp(dot, -1, 1))
		local rot = CFrame.fromAxisAngle(axis.Unit, angle)

		-- Apply rotation AFTER Roblox camera logic
		cam.CFrame = rot * cam.CFrame
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
