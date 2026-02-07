--[[
--nvim will import this module when trying to load mana.nvim.
--]]

if vim.g.loaded_mana then
return
end
vim.g.loaded_mana = true

local mana = require('mana')
mana.run()
