--[[
--Tests for tts module
--]]
--
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it
local assert = require('luassert')
local stub = require('luassert.stub')

describe('tts', function()
	local tts = require('mana.tts')

	it('engine', function()
		assert.is_equal(tts.engine, require('mana.espeak-ng'))
	end)

	it('speak', function()
		assert.is_function(tts.speak)
		stub(tts.engine, 'speak')
		tts.speak()
		assert.stub(tts.engine.speak).was_called(1)
		tts.engine.speak:revert()
	end)

	it('stop', function()
		assert.is_function(tts.stop)
		stub(tts.engine, 'stop')
		tts.stop()
		assert.stub(tts.engine.stop).was_called(1)
		tts.engine.stop:revert()
	end)
end)
