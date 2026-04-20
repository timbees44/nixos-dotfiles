-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- For example, changing the color scheme:
config.color_scheme = 'Gruvbox Material (Gogh)'

-- Hide tab bar
config.enable_tab_bar = false

-- Transparency
config.window_background_opacity = 0.9

-- Window bar
config.window_decorations = "RESIZE"

-- Do not prompt when closing windows launched for helper tasks
config.window_close_confirmation = "NeverPrompt"

-- Force the same login-shell startup path as the rest of macOS terminals.
config.default_prog = { "/bin/zsh", "-l" }

-- Remove default padding so the prompt hugs the top edge
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- and finally, return the configuration to wezterm
return config
