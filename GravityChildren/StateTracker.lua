local EPSILON = 0.1

local SPEED = {
	["onRunning"] = true,
	["onClimbing"] = true 
}

local INAIR = {
	["onFreeFall"] = true,
	["onJumping"] = true
}

local STATEMAP = {
	["onRunning"] = Enum.HumanoidStateType.Running,
	["onJumping"] = Enum.HumanoidStateType.Jumping,
	["onFreeFall"] = Enum.HumanoidStateType.Freefall
}

local StateTracker = {}
StateTracker.__index = StateTracker

function StateTracker.new(humanoid, soundState)
	local self = setmetatable({}, StateTracker)
	
	self.Humanoid = humanoid
	self.HRP = humanoid.RootPart
	
	self.Speed = 0
	self.State = "onRunning"
	self.Jumped = false
	
	self.SoundState = soundState
	
	self._ChangedEvent = Instance.new("BindableEvent")
	self.Changed = self._ChangedEvent.Event
	
	return self
end

function StateTracker:Destroy()
	self._ChangedEvent:Destroy()
end

function StateTracker:OnStep(gravityUp, grounded, isMoving)
	local cVelocity = self.HRP.Velocity
	local gVelocity = cVelocity:Dot(gravityUp)
	
	local oldState, oldSpeed = self.State, self.Speed
	
	local newState
	local newSpeed = cVelocity.Magnitude
	
	if (not grounded) then
		if (gVelocity > 0) then
			if (self.Jumped) then
				newState = "onJumping"
			else
				newState = "onFreeFall"
			end
		else
			if (self.Jumped) then
				self.Jumped = false
			end
			newState = "onFreeFall"
		end
	else
		newSpeed = (cVelocity - gVelocity*gravityUp).Magnitude
		newState = "onRunning"
	end
	
	newSpeed = isMoving and newSpeed or 0
	
	if (oldState ~= newState or (SPEED[newState] and math.abs(oldSpeed - newSpeed) > EPSILON)) then
		self.State = newState
		self.Speed = newSpeed
		self.SoundState:Fire(STATEMAP[newState])
		self._ChangedEvent:Fire(self.State, self.Speed)
	end
end

return StateTracker
