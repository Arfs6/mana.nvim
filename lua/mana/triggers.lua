--[[
--This module contains the part of mana.nvim that speaks automatically
--]]
--
local m = {}

local api = vim.api

local log = require('plenary.log').new({
	plugin = 'mana',
	level = 'debug',
})

local keys = require('mana.keys')
local tts = require('mana.tts')

m.on_key = function(key, typed)
	local text = keys[vim.fn.keytrans(typed)] or vim.fn.keytrans(typed)
	tts.stop()
	tts.speak(text)
end

m.events = {
	{
		events = {'CursorMoved', 'VimEnter'},
		opts = {
			callback = function(opts)
				log.info(opts.event)
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
				tts.speak(text)
				m.cursorPos = cursorPos
			end
		}
	},
	{
		events = {'BufLeave'},
		opts = {
			callback = function()
				m.cursorPos = nil
			end
		}
	}
}

m.init = function()
	vim.on_key(m.on_key, 0, {})

	for _, event in pairs(m.events) do
		api.nvim_create_autocmd(event.events, event.opts)
	end
end

return m
