local UIS = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local CameraModifier = {}
CameraModifier.__index = CameraModifier

function CameraModifier.new(player, controller)
	return self
end

function CameraModifier:Destroy()
	self.BaseClass.Update = self.DefaultUpdate
	self.BaseClass.GetUpVector = self.DefaultGetUpVector
	self.BaseClass.UpdateMouseBehavior = self.DefaultMouseBehavior
end

return CameraModifier
