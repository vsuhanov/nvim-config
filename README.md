# Make lazygit work

edit `~/Library/Application Support/lazygit/config.yml` (macOS) or `~/.config/lazygit/config.yml` (Linux)

```yaml
os:
  edit: '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "<C-\><C-N>:LazyGitEdit {{filename}}<CR>")'
  editInTerminal: true
  # editPreset: nvim-remote
notARepository: 'skip'
```
