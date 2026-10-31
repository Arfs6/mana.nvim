--[[
--espeak-ng is the default text to speech engine for mana.nvim.
--It requires the system libespeak-ng library.
--]]

local m = {}

local log = require('plenary.log').new({
	plugin = 'mana',
	level = 'debug',
	use_console = false,
})

local ffi = require('ffi')
local bit = require('bit')

-- Use plain C integer types for the espeak enums. This keeps these
-- declarations compatible with other espeak-ng bindings that may already
-- have been loaded through ffi.cdef.
pcall(ffi.cdef, [[
int espeak_Initialize(int output, int buflength, const char *path, int options);
int espeak_SetVoiceByName(const char *name);
int espeak_Synth(const void *text, size_t size, unsigned int position, int position_type,
	unsigned int end_position, unsigned int flags, unsigned int *unique_identifier, void *user_data);
int espeak_SetParameter(int parameter, int value, int relative);
int espeak_Cancel(void);
int espeak_Char(wchar_t character);
int espeak_Terminate(void);
]])

local AUDIO_OUTPUT_PLAYBACK = 0
local POS_CHARACTER = 1
local ESPEAK_RATE = 1
local ESPEAK_PUNCTUATION = 5
local ESPEAK_PUNCT_ALL = 1
local FLAGS = bit.bor(0x0, 0x100, 0x1000)

local function load_library()
	local candidates = { 'espeak-ng', 'libespeak-ng.so.1', 'libespeak-ng.so' }
	if jit.os == 'Windows' then
		candidates = { 'espeak-ng', [[C:\Program Files\eSpeak NG\libespeak-ng.dll]] }
	elseif jit.os == 'OSX' then
		candidates = { 'espeak-ng', 'libespeak-ng.dylib' }
	end

	for _, path in ipairs(candidates) do
		local ok, lib = pcall(ffi.load, path)
		if ok then
			return lib
		end
	end

	error(
		'mana: unable to load libespeak-ng; install espeak-ng or pass a custom tts engine to require("mana").setup()'
	)
end

local lib
local initialized = false
local identifier = ffi.new('unsigned int[1]')
local user_data = ffi.new('void *[1]')

m.init = function()
	if initialized then
		return
	end

	lib = load_library()
	lib.espeak_Initialize(AUDIO_OUTPUT_PLAYBACK, 0, nil, 0)
	lib.espeak_SetVoiceByName('en+Gene')
	lib.espeak_SetParameter(ESPEAK_RATE, 300, 0)
	lib.espeak_SetParameter(ESPEAK_PUNCTUATION, ESPEAK_PUNCT_ALL, 0)
	initialized = true
end

m.speak = function(text, opts)
	text = text or ''

	if not initialized then
		m.init()
	end

	log.debug('Speaking: ' .. vim.inspect(text))
	if #text == 1 then
		lib.espeak_Char(string.byte(text))
		return
	end

	lib.espeak_Synth(text, #text + 1, 0, POS_CHARACTER, 0, FLAGS, identifier, user_data)
end

m.stop = function()
	if not initialized then
		return
	end
	lib.espeak_Cancel()
end

m.uninit = function()
	if not initialized then
		return
	end
	lib.espeak_Terminate()
	initialized = false
	lib = nil
end

return m
