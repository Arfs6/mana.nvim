--[[
--Mana begins here.
--Call require('mana').setup() from your configuration.
--]]

local m = {}

local started = false

m.setup = function(config)
	local tts = require('mana.tts')
	tts.setup(config)

	if not started then
		require('mana.triggers').init()
		started = true
	end

	return m
end

m.init = m.setup

return m
