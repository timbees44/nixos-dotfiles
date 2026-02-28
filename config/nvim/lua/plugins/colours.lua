-- lua/plugins/colorscheme.lua
local colorscheme = "sonokai"

return {
	-- Gruvbox
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			if colorscheme == "gruvbox" then
				require("gruvbox").setup({
					contrast = "soft",
					transparent_mode = true,
				})
				vim.cmd.colorscheme("gruvbox")
			end
		end,
	},

	-- Sonokai
	{
		"sainnhe/sonokai",
		priority = 1000,
		config = function()
			if colorscheme == "sonokai" then
				vim.g.sonokai_enable_italic = true
				-- vim.g.sonokai_style = "andromeda" -- optional, or "default"
				vim.g.sonokai_transparent_background = 1
				vim.cmd.colorscheme("sonokai")
			  vim.api.nvim_set_hl(0, "TabLine",      { bg = "none" })
				vim.api.nvim_set_hl(0, "TabLineSel",   { bg = "none" })
				vim.api.nvim_set_hl(0, "TabLineFill",  { bg = "none" })
			end
		end,
	},

	-- Nord
	{
		'AlexvZyl/nordic.nvim',
		lazy = false,
		priority = 1000,
		config = function()
			if colorscheme == "nord" then
				require("nordic").setup({
					transparent = {
						bg = true, -- Enable transparent background
						float = true, -- Enable transparency for floating windows
					},
				})
				vim.cmd.colorscheme("nordic")
			end
		end,
	},
	{
		"vague-theme/vague.nvim",
		priority = 1000, -- make sure to load this before all the other plugins
		config = function()
			if colorscheme == "vague" then
				-- NOTE: you do not need to call setup if you don't want to.
				require("vague").setup({
					-- optional configuration here
					transparent = true
				})
				vim.cmd("colorscheme vague")
			end
		end,
	},

}
