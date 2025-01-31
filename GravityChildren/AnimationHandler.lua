local AnimationHandler = {}
AnimationHandler.__index = AnimationHandler

function AnimationHandler.new(humanoid, animate)
	local self = setmetatable({}, AnimationHandler)
	
	self._AnimFuncs = require(animate:WaitForChild("Controller"))
	self.Humanoid = humanoid
	
	return self
end

function AnimationHandler:EnableDefault(bool)
	if (bool) then
		self._AnimFuncs.onHook()
	else
		self._AnimFuncs.onUnhook()
	end
end

function AnimationHandler:Run(name, ...)
	self._AnimFuncs[name](...)
end

return AnimationHandler