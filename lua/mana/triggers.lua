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

local function clamp(value, min, max)
	if value < min then
		return min
	end
	if value > max then
		return max
	end
	return value
end

local function utf_end(line, col)
	if #line == 0 then
		return 0
	end

	col = clamp(col, 1, #line)
	local ok, offset = pcall(vim.str_utf_end, line, col)
	if not ok or type(offset) ~= 'number' or offset < 0 then
		return 0
	end
	return offset
end

-- Return the byte range to speak for a cursor move. All inputs are clamped
-- to the line so a stale or out-of-range cursor position cannot read outside
-- of the buffer line.
m.speechRange = function(prev, cur, line)
	line = line or ''

	if #line == 0 then
		return nil
	end

	if not prev or prev[1] ~= cur[1] then
		return { 1, #line }
	end

	local prev_col = clamp(prev[2] or 1, 1, #line)
	local cur_col = clamp(cur[2] or 1, 1, #line)

	if cur_col > prev_col then
		local text = line:sub(prev_col, cur_col)
		local end_col = clamp(cur_col + utf_end(line, cur_col), 1, #line)
		if vim.fn.strchars(text) == 2 then
			return { cur_col, end_col }
		end
		return { prev_col, end_col }
	elseif prev_col > cur_col then
		local text = line:sub(cur_col, prev_col)
		local end_col = clamp(cur_col + utf_end(line, cur_col), 1, #line)
		if vim.fn.strchars(text) == 2 then
			return { cur_col, end_col }
		end
		return { cur_col, clamp(prev_col + utf_end(line, prev_col), 1, #line) }
	end

	return { cur_col, clamp(cur_col + utf_end(line, cur_col), 1, #line) }
end

local function speak_range(prev, cur, line)
	local range = m.speechRange(prev, cur, line)
	if range then
		tts.speak(line:sub(range[1], range[2]))
	else
		tts.speak('')
	end
end

m.on_key = function(key, typed)
	local text = keys[vim.fn.keytrans(typed)] or vim.fn.keytrans(typed)
	tts.stop()
	tts.speak(text)
end

m.events = {
	{
		events = { 'CursorMoved', 'VimEnter' },
		opts = {
			callback = function(opts)
				log.info('Cursor moved.')
				local pos = vim.fn.getcurpos()
				local cursorPos = { pos[2], pos[3] }
				local line = api.nvim_get_current_line()
				speak_range(m.cursorPos, cursorPos, line)
				m.cursorPos = cursorPos
			end,
		},
	},
	{
		events = { 'BufLeave' },
		opts = {
			callback = function()
				m.cursorPos = nil
			end,
		},
	},
	{
		events = { 'CursorMovedC' },
		opts = {
			callback = function()
				local cmdPos = { 1, vim.fn.getcmdpos() }
				local line = vim.fn.getcmdtype() .. vim.fn.getcmdline()
				speak_range(m.cmdPos, cmdPos, line)
				m.cmdPos = cmdPos
			end,
		},
	},
	{
		events = { 'CmdlineLeave' },
		opts = {
			callback = function()
				m.cmdPos = nil
			end,
		},
	},
	{
		events = 'CursorMovedI',
		opts = {
			callback = function()
				log.debug('Cursor moved in insert mode')
				local pos = vim.fn.getcurpos()
				local insertCurPos = { pos[2], pos[3] }
				local line = api.nvim_get_current_line()
				speak_range(m.insertCurPos, insertCurPos, line)
				m.insertCurPos = insertCurPos
			end,
		},
	},
	{
		events = 'InsertLeave',
		opts = {
			callback = function()
				m.insertCurPos = nil
			end,
		},
	},
}

m.init = function()
	if m.initialized then
		return
	end
	m.initialized = true

	vim.on_key(m.on_key, 0, {})

	for _, event in pairs(m.events) do
		api.nvim_create_autocmd(event.events, event.opts)
	end

	local ns = vim.api.nvim_create_namespace('mana.nvim')

	vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
		if event ~= 'msg_show' then
			return
		end

		local _, content = ...
		local parts = {}
		for _, chunk in ipairs(content or {}) do
			if type(chunk) == 'table' and chunk[2] then
				parts[#parts + 1] = tostring(chunk[2])
			end
		end

		if #parts > 0 then
			tts.speak(table.concat(parts))
		end
	end)
end

return m
