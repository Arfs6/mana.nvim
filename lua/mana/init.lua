--[[
--Mana begins here.
--]]
local m = {}

local api = vim.api
local fn = vim.fn

local log = require('plenary.log').new({
	plugin = 'mana',
	level = 'debug',
})

local keys = require('mana.keys')

local espeak_ng = require('mana.espeak-ng')

vim.on_key(
	function(key, typed)
		local text = keys[vim.fn.keytrans(typed)] or vim.fn.keytrans(typed)
		if espeak_ng.speaking then
			espeak_ng.stop()
		end
		espeak_ng.speak(text)
	end,
	0,
	{}
)

vim.api.nvim_create_autocmd('CursorMoved', {
	callback = function()
		local pos = vim.fn.getcurpos()
		local cursorPos = { pos[2], pos[3] }
		if m.cursorPos and cursorPos[1] == m.cursorPos[1] then
			log.info('Cursor moved on the same line')
			if cursorPos[2] == m.cursorPos[2] + 1 or cursorPos[2] == m.cursorPos[2] -1 then
				local line = api.nvim_get_current_line()
				espeak_ng.speak(string.sub(line, cursorPos[2], cursorPos[2]))
			else
			espeak_ng.speak(fn.expand('<cword>'))
			end
		else
			log.info('Cursor moved to a different line')
			espeak_ng.speak(api.nvim_get_current_line())
		end
		m.cursorPos = { pos[2], pos[1] }
	end
})

vim.keymap.set('n', '<a-s>', function() espeak_ng.stop() end)

return m
