---
name: dotfile-maintenance
description: Maintain this Windows 11 and WSL2 Neovim, VS Code Neovim, and Herdr dotfile repository. Use when inspecting, changing, syncing, installing, or troubleshooting this repository's configuration, plugins, keymaps, setup scripts, or cross-platform behavior.
---

# Dotfile Maintenance

Maintain this repository without erasing machine differences or the user's existing work.

## Establish the current state

- Read the relevant sections of `README.md` and inspect `git status --short --branch` before changing files.
- Treat tracked, staged, untracked, and stashed changes as user work. Do not discard, overwrite, commit, push, or drop them unless explicitly requested.
- When work arrived from another PC, compare `HEAD`, the upstream branch, and the working tree before pulling. Preserve dirty changes in a named stash or commit only with authorization, use fast-forward updates where possible, and keep the safety copy until the merged result is verified.
- Inspect the current implementation instead of relying on the plugin list or behavior recorded here; the repository evolves continuously.

## Preserve repository invariants

- Support Windows 11 and WSL2 as the primary environments. Keep ordinary Linux viable when practical; do not claim macOS support without testing it.
- Do not put usernames, drive letters, credentials, tokens, private keys, or other machine-specific absolute paths in tracked files. Use environment variables, home-directory discovery, `vim.fs.joinpath`, or setup-time links.
- Assume Windows and WSL use separate clones synchronized through Git. Do not make WSL use the Windows checkout under `/mnt` as the normal setup.
- Use four-space indentation. Write code comments and documentation strings in polite Japanese `ですます調`.
- Avoid speculative feature or plugin growth. Add language support when it is needed and keep optional external dependencies documented.
- Python is the primary language. The intended secondary languages are C#, Dart/Flutter, HTML/CSS, JavaScript/TypeScript, and Lua.
- Debugging is intentionally handled in Visual Studio or VS Code. Do not restore Neovim DAP plugins or adapters unless the user explicitly changes that decision.
- Keep the memo and daily-log commands in `mycommand.lua` and their guarded Git helpers in `autocmds.lua` unless the user asks to remove them.

## Maintain Neovim behavior

- `nvim/init.lua` must detect `vim.g.vscode` before lazy.nvim setup. VS Code Neovim loads only `vscode-config.lua`; it must not load the normal UI, LSP, completion, or Notebook plugin stack.
- Put OS and executable detection in `nvim/lua/platform.lua` rather than scattering fixed paths across plugin files.
- Keep normal Neovim plugins separated by purpose through `plugins/core.lua`, `plugins/dev.lua`, and `plugins/workspace.lua`.
- Keep shared Vim cheat-sheet content in `vim_cheatsheet_data.lua` so normal Neovim and VS Code render the same entries. When adding a keymap useful to users, update the cheat sheet or README key table as appropriate.
- Preserve `Ctrl+A` as Select All in normal, insert, and visual modes for both normal Neovim and VS Code Neovim. Terminal mode keeps its native `Ctrl+A` behavior.
- Keep formatting manual through `<leader>cf` unless the user explicitly requests format-on-save.
- Keep `lazy-lock.json` tracked. When adding, removing, or syncing plugins, inspect its diff and avoid unrelated version churn. Preserve pre-existing lockfile edits.
- Mason-managed LSP and formatter binaries are per-machine state and are not synchronized by this repository.

## Maintain Herdr behavior

- `herdr/config.windows.toml` is the Windows config and explicitly uses PowerShell 7 through `default_shell = "pwsh"`.
- `herdr/config.toml` is the Unix/WSL config. Keep Linux-only commands out of the Windows config.
- `local.btop-sidebar` is Linux-only and requires `btop`, `python3`, and individual registration with `herdr plugin link`. Linking the whole plugin directory into the config directory does not register it.
- On Windows, `%APPDATA%\herdr\config.toml` should be a file symlink to the repository's Windows config. On WSL/Linux, `~/.config/herdr/config.toml` should link to the Unix config.
- Validate Herdr config with `herdr config check`. Reload a running server only when applying the change is within the user's request.

## Maintain setup scripts

- `install.ps1` and `install.sh` must be idempotent and must not overwrite an existing unrelated config or link.
- Check modes must remain read-only: `install.ps1 -Check` and `./install.sh --check` diagnose without changing setup state.
- Windows uses a junction for the Neovim config and a file symlink for the Herdr config. WSL/Linux uses directory and file symlinks.
- External package installation, PATH changes, plugin registration, and other machine-level mutations require confirmation immediately before execution.

## Validate proportionally

Run checks relevant to the changed files and report exactly what ran.

- Always run `git diff --check` and search for unresolved conflict markers after merge work.
- Run `stylua --check nvim` when StyLua is available and Lua files changed.
- Parse `nvim/lazy-lock.json` when it changed.
- Start normal Neovim headlessly with isolated state/cache and `-i NONE` after Neovim changes. Test the observable mapping or command behavior, not only module loading.
- When `vscode-config.lua`, shared keymaps, or the cheat sheet changes, test the VS Code branch with a stub `vscode` module and confirm the intended VS Code action.
- Parse `install.ps1` with the PowerShell parser and run `install.ps1 -Check` on Windows when setup code changes. Use `sh -n install.sh` and `./install.sh --check` in WSL/Linux when Unix setup changes.
- Run `herdr config check` after Herdr config changes. Respect that Windows sandbox access to the running Herdr server or user environment may require explicit escalation.

## Hand off clearly

- Summarize the behavior change, affected files, validation results, remaining external dependencies, and any intentionally retained stash.
- Distinguish repository changes from machine-local actions such as Winget/APT installs, Mason packages, environment variables, links, and Herdr plugin registration.
