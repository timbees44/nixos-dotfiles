local M = {}

-- New function that formats the file name using datetime
M.note_id_func = function(title)
  -- Get the current date and time in the format YYYY-MM-DD-HH-MM-SS
  local datetime = os.date("%Y-%m-%d")
  -- If no title is provided, use the datetime as the filename
  if not title or title == "" then
    title = "note"
  end
  -- Replace spaces with hyphens and ensure the filename is safe
  local file_name = title:gsub(" ", "-"):gsub("[^A-Za-z0-9%-%_]", ""):lower()
  -- Combine the datetime with the cleaned-up title to generate the final filename
  local formatted_file_name = datetime .. "_" .. file_name .. ".md"
  return formatted_file_name
end

return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
  --   "BufReadPre path/to/my-vault/**.md",
  --   "BufNewFile path/to/my-vault/**.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies
  },
  opts = {
    ui = {
      enable = false,
    },
    workspaces = {
      {
        name = "personal",
        path = "~/Documents/second_brain",
      },
    },

    -- Daily note config
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "daily",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "/%Y/%m-%B/%Y-%m-%d-%A",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%B %-d, %Y",
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = "Daily.md",
    },

    -- Optional, for templates (see below).
    templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {},
    },

    -- Using the function inside obsidian.nvim's opts (optional)
    note_id_func = M.note_id_func,
    config = function()
      -- Optional: Define additional configurations or functions for obsidian.nvim here
    end,
  },
}
