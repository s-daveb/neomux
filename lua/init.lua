local Module = {}

-- Default configuration
local defaults = {
  no_mappings = false, -- Disable default key mappings
  save_on_switch = 0,  -- 0 = no save, 1 = save current buffer, 2 = save all buffers
  disable_when_zoomed = false, -- Disable navigation when tmux pane is zoomed
  preserve_zoom = false, -- Preserve zoom state when navigating
  no_wrap = false, -- Prevent wrap-around navigation
  keymaps = { -- Default key mappings
    left = "<C-h>",
    down = "<C-j>",
    up = "<C-k>",
    right = "<C-l>",
    previous = "<C-\\>"
  }
}

local config

-- Private helper functions
local function tmux_command(args)
  local socket = os.getenv("TMUX") and vim.split(os.getenv("TMUX"), ',')[1] or ""
  local executable = string.find(os.getenv("TMUX") or "", "tmate") and "tmate" or "tmux"
  local cmd = string.format("%s -S %s %s", executable, socket, args)
  return vim.fn.system(cmd)
end

local function is_zoomed()
  return tmux_command("display-message -p '#{window_zoomed_flag}'"):match("1")
end

local function should_forward_to_tmux(at_tab_page_edge)
  if config.disable_when_zoomed and is_zoomed() then
    return false
  end
  return at_tab_page_edge
end

local function navigate_in_vim(direction)
  vim.cmd("wincmd " .. direction)
end

local function navigate(direction)
  local nr = vim.fn.winnr()
  navigate_in_vim(direction)

  local at_tab_page_edge = (nr == vim.fn.winnr())
  if should_forward_to_tmux(at_tab_page_edge) then
    if config.save_on_switch == 1 then
      pcall(vim.cmd, "update")
    elseif config.save_on_switch == 2 then
      pcall(vim.cmd, "wall")
    end

    local tmux_direction = ({ h = "L", j = "D", k = "U", l = "R" })[direction] or ""
    local args = string.format("select-pane -%s", tmux_direction)

    if config.preserve_zoom then
      args = args .. " -Z"
    end

    tmux_command(args)
  end
end

-- Public API
function Module.navigate_left()
  navigate("h")
end

function Module.navigate_down()
  navigate("j")
end

function Module.navigate_up()
  navigate("k")
end

function Module.navigate_right()
  navigate("l")
end

function Module.navigate_previous()
  navigate("p")
end

function Module.setup(opts)
  config = vim.tbl_deep_extend("force", {}, defaults, opts or {})

  -- Set up user commands
  vim.api.nvim_create_user_command("TmuxNavigateLeft", Module.navigate_left, {})
  vim.api.nvim_create_user_command("TmuxNavigateDown", Module.navigate_down, {})
  vim.api.nvim_create_user_command("TmuxNavigateUp", Module.navigate_up, {})
  vim.api.nvim_create_user_command("TmuxNavigateRight", Module.navigate_right, {})
  vim.api.nvim_create_user_command("TmuxNavigatePrevious", Module.navigate_previous, {})

  -- Set up default keymaps if not disabled
  if not config.no_mappings then
    local keymaps = config.keymaps
    vim.keymap.set("n", keymaps.left, "<Cmd>TmuxNavigateLeft<CR>", { silent = true })
    vim.keymap.set("n", keymaps.down, "<Cmd>TmuxNavigateDown<CR>", { silent = true })
    vim.keymap.set("n", keymaps.up, "<Cmd>TmuxNavigateUp<CR>", { silent = true })
    vim.keymap.set("n", keymaps.right, "<Cmd>TmuxNavigateRight<CR>", { silent = true })
    vim.keymap.set("n", keymaps.previous, "<Cmd>TmuxNavigatePrevious<CR>", { silent = true })
  end
end

return Module
