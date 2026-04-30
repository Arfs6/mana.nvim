--[[
--tts is the module that takes care of text to speech engines
--]]
--
local m = {}

m.engine = require('mana.espeak-ng')

m.speak = function(text)
	m.engine.speak(text)
end

m.stop = function()
	m.engine.stop()
end

return m
