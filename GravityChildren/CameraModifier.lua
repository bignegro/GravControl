local UIS = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CameraModifier = {}
CameraModifier.__index = CameraModifier

function CameraModifier.new(player)
	local self = setmetatable({}, CameraModifier)
	
	local playerModule = player.PlayerScripts:WaitForChild("PlayerModule")
	local cameraModule = playerModule:WaitForChild("CameraModule")
	local basecam = require(cameraModule:WaitForChild("BaseCamera"))
	
	self.IsCamLocked = false
	self.BaseClass = basecam
	self.DefaultMouseBehavior = basecam.UpdateMouseBehavior
	
	function basecam.UpdateMouseBehavior(this)
		-- sometimes this wasn't working in server testing but seems to be fine in real games
		if this.inFirstPerson or this.inMouseLockedMode then
			UserGameSettings.RotationType = Enum.RotationType.MovementRelative
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			
			self.IsCamLocked = true
		else
			UserGameSettings.RotationType = Enum.RotationType.MovementRelative
			if this.isRightMouseDown or this.isMiddleMouseDown then
				UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			else
				UIS.MouseBehavior = Enum.MouseBehavior.Default
			end
			
			self.IsCamLocked = false
		end
	end
	
	return self
end

-- Public methods

function CameraModifier:Destroy()
	self.BaseClass.UpdateMouseBehavior = self.DefaultMouseBehavior
end

--

return CameraModifier