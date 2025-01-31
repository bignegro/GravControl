local Draw2DModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/bignegro/GravControl/refs/heads/main/DrawClassChildren/Draw2D.lua"))()
local Draw3DModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/bignegro/GravControl/refs/heads/main/DrawClassChildren/Draw3D.lua"))()

--

local DrawClass = {}
local DrawClassStorage = setmetatable({}, {__mode = "k"})
DrawClass.__index = DrawClass

function DrawClass.new(parent)
	local self = setmetatable({}, DrawClass)
	
	self.Parent = parent
	DrawClassStorage[self] = {}
	
	self.Draw3D = {}
	for key, func in next, Draw3DModule do
		self.Draw3D[key] = function(...)
			local returns = {func(self.Parent, ...)}
			for i = 1, #returns do
				table.insert(DrawClassStorage[self], returns[i])
			end
			return unpack(returns)
		end
	end
	
	self.Draw2D = {}
	for key, func in next, Draw2DModule do
		self.Draw2D[key] = function(...)
			local returns = {func(self.Parent, ...)}
			for i = 1, #returns do
				table.insert(DrawClassStorage[self], returns[i])
			end
			return unpack(returns)
		end
	end
	
	return self
end

--

function DrawClass:Clear()
	local t = DrawClassStorage[self]
	while (#t > 0) do
		local part = table.remove(t)
		if (part) then
			part:Destroy()
		end
	end
	DrawClassStorage[self] = {}
end

--

return DrawClass
