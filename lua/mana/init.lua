--[[
--Mana begins here.
--]]
local m = {}

local log = require('plenary.log').new({
	plugin = 'mana',
	level = 'debug',
})

local triggers = require('mana.triggers')
triggers.init()

return m
