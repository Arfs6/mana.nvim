# AGENTS.md

Mana is a Neovim plugin that speaks typed keys, cursor movement, and command-line changes through a pluggable TTS engine.

## Setup API

- `plugin/mana.lua` only guards loading and requires `mana`; it does not start Mana.
- Users must call `require('mana').setup()` (also available as `require('mana').init`).
- `setup(opts)` accepts:

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

- Every engine must implement `init`, `speak`, `stop`, and `uninit`.
- With no engine configured, `mana.tts` uses `lua/mana/espeak-ng.lua`.
- `tts.setup()` calls `engine.init()`. Replacing an engine calls the previous engine's `uninit()`.
- The default engine requires the system `libespeak-ng` library.
- The external `arfs6/espeak-ng.lua` engine can be passed instead; it must be on `runtimepath` and its `audio.so` built with `just build`.

## Architecture

- `plugin/mana.lua` -> `lua/mana/init.lua` -> `lua/mana/tts.lua` + `lua/mana/triggers.lua`.
- `lua/mana/triggers.lua` registers `vim.on_key` and autocmds, then speaks the relevant text.
- `triggers.speechRange(prev, cur, line)` computes the byte range to speak. It clamps positions to the line and handles UTF-8 boundaries; keep it that way when changing cursor logic.
- `lua/mana/keys.lua` maps key-translated names (for example `<CR>`) to spoken phrases.
- `lua/mana/tts.lua` is the engine abstraction and validates the required interface.

## Launching

Use the dedicated app configuration:

```sh
NVIM_APPNAME='mana' nvim
```

This loads `~/.config/mana/init.lua`, which is where the repository and its dependencies should be added to `runtimepath`. Plain `nvim` will only load Mana if the normal configuration already includes it.

## Tests

Tests are plenary.nvim busted specs under `tests/`. Run them from the repository root so the test harness can add the repository to `runtimepath`:

```sh
nvim --headless -u NONE \
	--cmd 'set rtp+=~/.local/share/nvim/lazy/plenary.nvim' \
	--cmd 'runtime plugin/plenary.vim' \
	-c 'PlenaryBustedDirectory tests'
```

Run one spec file:

```sh
nvim --headless -u NONE \
	--cmd 'set rtp+=~/.local/share/nvim/lazy/plenary.nvim' \
	--cmd 'runtime plugin/plenary.vim' \
	-c 'PlenaryBustedFile tests/tts_spec.lua'
```

Adjust the plenary path if it is installed elsewhere. Tests should use fake engines or stubs instead of starting real audio playback.

## Commits

- Make one commit per logical change.
- Use this message format:

```text
type(scope) - summary

Optional details explaining what changed and why.
```

- Example:

```text
feat(triggers.lua) - added command-line speech

Speaks the newly typed range when the command line changes.
```

- Common types: `feat`, `fix`, `docs`, `test`, `refactor`.
- Use the file or module name as the scope, such as `triggers.lua`, `tts.lua`, or `readme.md`.

## Conventions

- There is no CI, formatter, linter, or root manifest; do not invent lint, format, or typecheck commands.
- Keep the default engine usable without the external `espeak-ng.lua` repository.
- Do not commit generated or machine-specific files.
