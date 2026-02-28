local servers = {
  "html",
  "cssls",
  "tailwindcss",
  "lua_ls",
  "graphql",
  "emmet_ls",
  "pyright",
}

local function auto_install_enabled()
  if vim.g.mason_auto_install ~= nil then
    return vim.g.mason_auto_install
  end

  local env = vim.env.MASON_AUTO_INSTALL
  if env then
    env = env:lower()
    if env == "1" or env == "true" or env == "yes" then
      return true
    elseif env == "0" or env == "false" or env == "no" then
      return false
    end
  end

  return false
end

return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      local enable_auto = auto_install_enabled()
      opts = opts or {}
      opts.ensure_installed = enable_auto and servers or {}
      opts.automatic_installation = enable_auto
      return opts
    end,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
}
