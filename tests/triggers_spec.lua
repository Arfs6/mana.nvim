--[[
-- Tests all the testable parts of `triggers.lua`
--]]
--
local describe = require('plenary.busted').describe
local it = require('plenary.busted').it
local assert = require('luassert')

describe('speechRange', function()
	local triggers = require('mana.triggers')

	it('speaks the whole line when prev is nil', function()
		local line = 'This is a line'
		local range = triggers.speechRange(nil, { 1, 1 }, line)
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], #line)
	end)

	it('speaks the whole line when the line changed', function()
		local line = 'This is a line'
		local range = triggers.speechRange({ 1, 3 }, { 2, 1 }, line)
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], #line)
	end)

	it('returns nil for an empty line', function()
		assert.is_nil(triggers.speechRange({ 1, 1 }, { 1, 1 }, ''))
	end)

	it('speaks only the new character when moving forward one character', function()
		local line = 'This is a line'
		local range = triggers.speechRange({ 1, 1 }, { 1, 2 }, line)
		assert.is_equal(range[1], 2)
		assert.is_equal(range[2], 2)
	end)

	it('speaks the traversed range when moving forward multiple characters', function()
		local line = 'This is a line'
		local range = triggers.speechRange({ 1, 1 }, { 1, 3 }, line)
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], 3)

		line = '12é45'
		range = triggers.speechRange({ 1, 1 }, { 1, 3 }, line)
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], 4)

		range = triggers.speechRange({ 1, 3 }, { 1, 6 }, line)
		assert.is_equal(range[1], 3)
		assert.is_equal(range[2], 6)
	end)

	it('speaks only the new character when moving backward one character', function()
		local range = triggers.speechRange({ 1, 2 }, { 1, 1 }, 'hello')
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], 1)
	end)

	it('speaks the traversed range when moving backward multiple characters', function()
		local range = triggers.speechRange({ 1, 3 }, { 1, 1 }, 'hello')
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], 3)

		local line = '12é45'
		range = triggers.speechRange({ 1, 6 }, { 1, 3 }, line)
		assert.is_equal(range[1], 3)
		assert.is_equal(range[2], 6)

		range = triggers.speechRange({ 1, 3 }, { 1, 1 }, line)
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], 4)
	end)

	it('handles multibyte characters when moving forward one character', function()
		local line = 'aé漢x'
		local cur = { 1, 2 }
		local prev = { 1, 1 }
		local expected = { cur[2], cur[2] + vim.str_utf_end(line, cur[2]) }
		local range = triggers.speechRange(prev, cur, line)
		assert.is_equal(range[1], expected[1])
		assert.is_equal(range[2], expected[2])
	end)

	it('handles multibyte characters when moving backward one character', function()
		local line = 'aé漢x'
		local cur = { 1, 1 }
		local prev = { 1, 2 }
		local expected = { cur[2], cur[2] + vim.str_utf_end(line, cur[2]) }
		local range = triggers.speechRange(prev, cur, line)
		assert.is_equal(range[1], expected[1])
		assert.is_equal(range[2], expected[2])
	end)

	it('clamps columns past the end of the line', function()
		local range = triggers.speechRange({ 1, 1 }, { 1, 999 }, 'hello')
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], #'hello')
	end)

	it('clamps columns before the start of the line', function()
		local range = triggers.speechRange({ 1, -10 }, { 1, 1 }, 'hello')
		assert.is_equal(range[1], 1)
		assert.is_equal(range[2], 1)
	end)
end)
