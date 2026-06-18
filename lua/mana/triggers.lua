--[[
--This module contains the part of mana.nvim that speaks automatically
--]]
--
local m = {}

local api = vim.api

local log = require('plenary.log').new({
	plugin = 'mana',
	level = 'debug',
	use_console = false,
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
	},
	{
		events = {'CursorMovedC'},
		opts = {
			callback = function()
				local cmdPos = vim.fn.getcmdpos()
				local line = vim.fn.getcmdtype() .. vim.fn.getcmdline()
				local text
				if m.cmdPos == nil then
					m.cmdPos = 1
				end
				if m.cmdPos > cmdPos then
					text = string.sub(line, cmdPos, m.cmdPos)
					if #text == 2 then
						text = string.sub(text, 1, 1)
					end
				else
					text = string.sub(line, m.cmdPos, cmdPos)
					if #text == 2 then
						text = string.sub(text, 2, 2)
					end
				end
				tts.speak(text)
				m.cmdPos = cmdPos
			end
		}
	},
	{
		events = {'CmdlineLeave'},
		opts = {
			callback = function()
				m.cmdPos = nil
			end
		}
	},
	{
		events = 'CursorMovedI',
		opts = {
			callback = function()
				log.debug('Cursor moved in insert mode')
				local pos = vim.fn.getcurpos()
				local insertCurPos = { pos[2], pos[3] }
				local line = api.nvim_get_current_line()
				local text = ''
				if m.insertCurPos and insertCurPos[1] == m.insertCurPos[1] then
					if m.insertCurPos[2] > insertCurPos[2] then
						text = string.sub(line, insertCurPos[2], m.insertCurPos[2])
						if #text == 2 then
							text = string.sub(text, 1, 1)
						end
					else
						text = string.sub(line, m.insertCurPos[2], insertCurPos[2])
						if #text == 2 then
							text = string.sub(text, 2, 2)
						end
					end
				else
					text = line
				end
				tts.speak(text)
				m.insertCurPos = insertCurPos
			end
		}
	},
	{
		events = 'InsertLeave',
		opts = {
			callback = function()
				m.inseertCurPos = nil
			end
		}
	}
}

m.init = function()
	vim.on_key(m.on_key, 0, {})

	for _, event in pairs(m.events) do
		api.nvim_create_autocmd(event.events, event.opts)
	end

	local ns = vim.api.nvim_create_namespace('mana.nvim')

	vim.ui_attach(ns, {ext_messages=true}, function(event, ...)
		if event == 'msg_show' then
			local kind, content, replace_last, history, append, id, trigger = ...
			local text = ''
			for _, chunk in ipairs(content) do
				text = text .. chunk[2]
			end
			tts.speak(text)
		end
	end)
end

return m
