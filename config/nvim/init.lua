vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt
local fn = vim.fn
local api = vim.api

local augroup = api.nvim_create_augroup("core_config", { clear = true })

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 10
opt.sidescrolloff = 8

opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.showmatch = true
opt.matchtime = 2
opt.cmdheight = 1
opt.completeopt = { "menuone", "noselect", "popup" }
opt.showmode = false
opt.pumheight = 10
opt.pumblend = 10
opt.winblend = 0
opt.conceallevel = 0
opt.concealcursor = ""
opt.showtabline = 0

opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = fn.expand("~/.vim/undodir")
opt.updatetime = 300
opt.autoread = true
opt.autowrite = false

opt.hidden = true
opt.errorbells = false
opt.backspace = "indent,eol,start"
opt.autochdir = false
opt.selection = "exclusive"
opt.mouse = "a"
opt.clipboard:append("unnamedplus")
opt.encoding = "UTF-8"
opt.path:append("**")
opt.iskeyword:append("-")

api.nvim_set_hl(0, "Normal", { bg = "none" })
api.nvim_set_hl(0, "NormalNC", { bg = "none" })
api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
api.nvim_set_hl(0, "SignColumn", { bg = "none" })
api.nvim_set_hl(0, "StatusLine", { bg = "none" })

local gh = function(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  { src = gh("sainnhe/sonokai") },
  { src = gh("nvim-lua/plenary.nvim") },
  { src = gh("nvim-telescope/telescope.nvim") },
  { src = gh("nvim-treesitter/nvim-treesitter") },
  { src = gh("windwp/nvim-autopairs") },
  { src = gh("MeanderingProgrammer/render-markdown.nvim") },
  { src = gh("echasnovski/mini.nvim") },
}, { confirm = false, load = true })

vim.g.sonokai_enable_italic = true
vim.g.sonokai_transparent_background = 1
vim.cmd.colorscheme("sonokai")
api.nvim_set_hl(0, "TabLine", { bg = "none" })
api.nvim_set_hl(0, "TabLineSel", { bg = "none" })
api.nvim_set_hl(0, "TabLineFill", { bg = "none" })

require("nvim-autopairs").setup({
  check_ts = false,
  enable_check_bracket_line = true,
})

require("telescope").setup({
  defaults = {
    hidden = true,
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
    },
    file_ignore_patterns = {
      "venv",
      ".git",
    },
  },
  pickers = {
    find_files = {
      hidden = true,
      no_ignore = true,
    },
  },
})

pcall(function()
  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "bash",
      "css",
      "html",
      "javascript",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "yaml",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "markdown" },
    },
  })
end)

require("render-markdown").setup({
  render_modes = true,
  file_types = { "markdown" },
  anti_conceal = {
    enabled = true,
    ignore = {
      code_background = false,
      sign = true,
    },
    above = 0,
    below = 0,
  },
  bullet = { right_pad = 1 },
  heading = {
    position = "inline",
    width = "full",
    icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
  },
  checkbox = {
    right_pad = 1,
  },
  code = {
    enabled = true,
    style = "full",
    width = "block",
    language_icon = true,
  },
})

local function set_markdown_highlights()
  api.nvim_set_hl(0, "@markup.strong", { link = "MoreMsg", bold = true })
  api.nvim_set_hl(0, "@markup.italic", { link = "SpecialKey", italic = true })
end

set_markdown_highlights()

api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = set_markdown_highlights,
})

local telescope_builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>c", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete!<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("n", "<leader>e", "<cmd>Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fm", function()
  vim.lsp.buf.format()
end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>w", vim.diagnostic.open_float, { desc = "Line diagnostics" })

api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    local lcount = api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client == nil then
      return
    end

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    local map = function(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
    end

    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("K", vim.lsp.buf.hover, "Hover")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})

vim.keymap.set("i", "<C-Space>", function()
  vim.lsp.completion.get()
end, { desc = "Trigger completion" })

do
  local enabled = {}

  if fn.executable("lua-language-server") == 1 then
    vim.lsp.config("lua_ls", {
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })
    table.insert(enabled, "lua_ls")
  end

  if fn.executable("basedpyright") == 1 then
    vim.lsp.config("basedpyright", {
      cmd = { "basedpyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
      },
    })
    table.insert(enabled, "basedpyright")
  elseif fn.executable("pyright-langserver") == 1 then
    vim.lsp.config("pyright", {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
      },
    })
    table.insert(enabled, "pyright")
  end

  if #enabled > 0 then
    vim.lsp.enable(enabled)
  end
end

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

local terminal_state = {
  buf = -1,
  win = -1,
}

api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e1e" })
api.nvim_set_hl(0, "FloatBorder", { fg = "#ffffff", bg = "#1e1e1e" })

local function create_floating_window()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = terminal_state.buf
  if not api.nvim_buf_is_valid(buf) then
    buf = api.nvim_create_buf(false, true)
  end

  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  })

  return buf, win
end

local function toggle_terminal()
  if not api.nvim_win_is_valid(terminal_state.win) then
    terminal_state.buf, terminal_state.win = create_floating_window()
    if vim.bo[terminal_state.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
    end
    vim.cmd.startinsert()
  else
    api.nvim_win_hide(terminal_state.win)
  end
end

api.nvim_create_user_command("Floaterminal", toggle_terminal, {})
vim.keymap.set("n", "<leader>tt", toggle_terminal, { desc = "Toggle floating terminal" })
vim.keymap.set("t", "<C-t>", toggle_terminal, { desc = "Toggle floating terminal" })
