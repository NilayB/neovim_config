return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = { "clangd", "--background-index", "--fallback-style=Microsoft" },
      },
    },
  },
}
