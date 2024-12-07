neomux
==================
This plugin is a shameless, quick and dirty AI-assisted port of Chris Toomey's [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator).
I just wanted this for personal use, and was wondering how hard it would be to do port it with thes new genAI tools.
I'm not sure that I want to maintain this, but feel free to fork it and use it for your own purposes.

I am licensing this port under the Unlicense, but the original is MIT licensed,
and as such, you must credit Chris Toomey if you tweak and publish this code.

**NOTE**: This requires tmux v1.8 or higher.

Usage
-----

This plugin provides the following mappings which allow you to move between
Vim panes and tmux splits seamlessly.

- `<ctrl-h>` => Left
- `<ctrl-j>` => Down
- `<ctrl-k>` => Up
- `<ctrl-l>` => Right
- `<ctrl-\>` => Previous split

**Note** - you don't need to use your tmux `prefix` key sequence before using
the mappings.

To customize key bindings or other options, refer to the [configuration section](#configuration).

Installation
------------

### lazy.nvim

If you are using [lazy.nvim](https://github.com/folke/lazy.nvim), you can install `neomux` as a local or remote plugin. Here's how:

#### Example Lazy Plugin Configuration

```lua
{
  -- Replace with the actual path to your local plugin
  dir = "~/path/to/neomux",
  name = "neomux",
  config = function()
    require("neomux").setup({
      no_mappings = false, -- Disable default key mappings if true
      save_on_switch = 1,  -- Save buffers when switching to tmux (0 = none, 1 = current buffer, 2 = all buffers)
      disable_when_zoomed = true, -- Disable navigation when tmux pane is zoomed
      preserve_zoom = true, -- Preserve zoom state when navigating
      no_wrap = false, -- Disable wrap-around navigation in tmux
      keymaps = {
        left = "<C-h>", -- Key to navigate left
        down = "<C-j>", -- Key to navigate down
        up = "<C-k>",   -- Key to navigate up
        right = "<C-l>", -- Key to navigate right
        previous = "<C-\\>", -- Key to navigate to the previous pane
      },
    })
  end,
}
```

Options
---

| Option               | Type    | Default        | Description                                                                 |
|----------------------|---------|----------------|-----------------------------------------------------------------------------|
| `no_mappings`        | boolean | `false`        | Disable default key mappings if `true`.                                    |
| `save_on_switch`     | number  | `0`            | Save buffers when switching to tmux: `0` = none, `1` = current buffer, `2` = all buffers. |
| `disable_when_zoomed`| boolean | `false`        | Disable navigation when the tmux pane is zoomed.                           |
| `preserve_zoom`      | boolean | `false`        | Preserve zoom state when navigating between tmux panes.                    |
| `no_wrap`            | boolean | `false`        | Disable wrap-around navigation when reaching the edge of tmux panes.       |
| `keymaps`            | table   | See below      | Key mappings for navigation commands.                                      |

#### Default Keymaps

| Key        | Default Mapping | Description                 |
|------------|-----------------|-----------------------------|
| `left`     | `<C-h>`         | Navigate to the left pane.  |
| `down`     | `<C-j>`         | Navigate to the bottom pane.|
| `up`       | `<C-k>`         | Navigate to the top pane.   |
| `right`    | `<C-l>`         | Navigate to the right pane. |
| `previous` | `<C-\\>`        | Navigate to the previous pane.|

TMUX Configuration
---
### Smart pane switching with awareness of Vim splits
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'
bind-key -n 'C-\\' if-shell "$is_vim" 'send-keys C-\\' 'select-pane -l'


Example
---

require("neomux").setup({
  no_mappings = true, -- Disable default keymaps
  save_on_switch = 2, -- Save all buffers when switching
  keymaps = {
    left = "<M-h>", -- Alt-h to navigate left
    down = "<M-j>", -- Alt-j to navigate down
    up = "<M-k>",   -- Alt-k to navigate up
    right = "<M-l>", -- Alt-l to navigate right
    previous = "<M-\\>", -- Alt-\ to go to the previous pane
  },
})
