# Mana

Mana is a Neovim plugin that reduces friction between Neovim and screen
readers by speaking typed keys, cursor movement, and command-line changes.

## Requirements

- Neovim
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- `libespeak-ng` for the default text-to-speech engine

## Installation

With lazy.nvim:

```lua
{
	'Arfs6/mana.nvim',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		require('mana').setup()
	end,
}
```

## Setup

Call `setup()` once from your Neovim configuration:

```lua
require('mana').setup()
```

With no options, Mana uses the built-in espeak-ng engine from
`lua/mana/espeak-ng.lua`.

### Custom TTS engine

Pass any engine that implements `init`, `speak`, `stop`, and `uninit`:

```lua
require('mana').setup({
	tts = {
		engine = {
			init = function() end,
			speak = function(text) end,
			stop = function() end,
			uninit = function() end,
		},
	},
})
```

- `init` is called once when Mana is set up.
- `speak(text)` receives the text to speak.
- `stop()` cancels current speech.
- `uninit()` releases the engine when it is replaced or Mana is unloaded.

### Using arfs6/espeak-ng.lua

The external [arfs6/espeak-ng.lua](https://github.com/arfs6/espeak-ng.lua)
engine can be used instead:

1. Add `espeak-ng.lua` to `runtimepath`.
2. Build its audio module with `just build` in that repository.
3. Pass its engine to Mana:

```lua
require('mana').setup({
	tts = {
		engine = require('espeak-ng.mana'),
	},
})
```

## Launching

To run Mana with a dedicated Neovim app configuration, use:

```sh
NVIM_APPNAME='mana' nvim
```

This loads `~/.config/mana/init.lua` instead of the normal Neovim
configuration, so the plugin can be tested without changing your main setup.

## Tests

Tests use plenary.nvim's busted runner. From the repository root:

```sh
nvim --headless -u NONE \
	--cmd 'set rtp+=~/.local/share/nvim/lazy/plenary.nvim' \
	--cmd 'runtime plugin/plenary.vim' \
	-c 'PlenaryBustedDirectory tests'
```

## License

This plugin is licensed under the MIT license.
