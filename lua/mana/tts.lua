--[[
--tts is the module that takes care of text to speech engines.
--An engine must provide init, speak, stop, and uninit functions.
--]]

local m = {}

local required_functions = { 'init', 'speak', 'stop', 'uninit' }

local function validate_engine(engine)
	if type(engine) ~= 'table' then
		error('mana.tts: engine must be a table', 3)
	end

	for _, name in ipairs(required_functions) do
		if type(engine[name]) ~= 'function' then
			error(('mana.tts: engine is missing required function "%s"'):format(name), 3)
		end
	end
end

m.resolve_engine = function(config)
	if config and config.tts and config.tts.engine then
		return config.tts.engine
	end
	return require('mana.espeak-ng')
end

m.set_engine = function(engine)
	validate_engine(engine)

	if m.engine and m.engine ~= engine then
		pcall(m.engine.uninit)
	end

	m.engine = engine
end

m.setup = function(config)
	config = config or {}
	m.set_engine(m.resolve_engine(config))
	m.engine.init()
end

m.speak = function(text)
	if not m.engine then
		return
	end
	m.engine.speak(text or '')
end

m.stop = function()
	if not m.engine then
		return
	end
	m.engine.stop()
end

m.uninit = function()
	if not m.engine then
		return
	end
	m.engine.uninit()
	m.engine = nil
end

return m
