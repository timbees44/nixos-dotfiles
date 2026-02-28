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

-- and finally, return the configuration to wezterm
return config
