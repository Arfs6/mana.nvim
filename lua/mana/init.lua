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
		espeak_ng.stop()
		espeak_ng.speak(text)
	end,
	0,
	{}
)

vim.api.nvim_create_autocmd('CursorMoved', {
	callback = function()
		log.info('Cursor moved.')
		local pos = vim.fn.getcurpos()
		local cursorPos = { pos[2], pos[3] }
		local line = api.nvim_get_current_line()
		local text = ''
		if m.cursorPos and cursorPos[1] == m.cursorPos[1] then
			if m.cursorPos[2] > cursorPos[2] then
				text = string.sub(line, cursorPos[2], m.cursorPos[2])
				if #text == 2 then
					text = string.sub(text, 1, 1)
				end
			else
				text = string.sub(line, m.cursorPos[2], cursorPos[2])
				if #text == 2 then
					text = string.sub(text, 2, 2)
				end
			end
		else
			text = line
		end
		espeak_ng.speak(text)
		m.cursorPos = cursorPos
	end
})

vim.keymap.set('n', '<a-s>', function() espeak_ng.stop() end)

return m
