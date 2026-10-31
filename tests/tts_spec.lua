--[[
--Tests for tts module
--]]
--
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it
local after_each = require('plenary.busted').after_each
local assert = require('luassert')
local stub = require('luassert.stub')

local tts = require('mana.tts')

local function new_engine()
	return {
		init = function() end,
		speak = function() end,
		stop = function() end,
		uninit = function() end,
	}
end

describe('tts', function()
	after_each(function()
		tts.uninit()
	end)

	it('uses mana.espeak-ng when no engine is configured', function()
		assert.is_equal(tts.resolve_engine({}), require('mana.espeak-ng'))
	end)

	it('uses a configured engine', function()
		local engine = new_engine()
		assert.is_equal(tts.resolve_engine({ tts = { engine = engine } }), engine)
	end)

	it('initializes the engine on setup', function()
		local engine = new_engine()
		local calls = 0
		engine.init = function()
			calls = calls + 1
		end

		tts.setup({ tts = { engine = engine } })

		assert.is_equal(calls, 1)
		assert.is_equal(tts.engine, engine)
	end)

	it('rejects an engine missing required functions', function()
		assert.has_error(function()
			tts.set_engine({ init = function() end })
		end)
	end)

	it('speak', function()
		local engine = new_engine()
		tts.set_engine(engine)
		stub(engine, 'speak')
		tts.speak('hello')
		assert.stub(engine.speak).was_called(1)
		engine.speak:revert()
	end)

	it('stop', function()
		local engine = new_engine()
		tts.set_engine(engine)
		stub(engine, 'stop')
		tts.stop()
		assert.stub(engine.stop).was_called(1)
		engine.stop:revert()
	end)

	it('uninit', function()
		local engine = new_engine()
		tts.set_engine(engine)
		stub(engine, 'uninit')
		tts.uninit()
		assert.stub(engine.uninit).was_called(1)
		engine.uninit:revert()
		assert.is_nil(tts.engine)
	end)
end)
