return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    if type(opts.ensure_installed) == "table" then
      vim.list_extend(opts.ensure_installed, {
        "glsl",
        "hlsl",
        "wgsl",
      })

    -- Disable Tree-sitter indentation for C and C++
    opts.indent = opts.indent or { enable = true }
    opts.indent.disable = { "c", "cpp" }
    end
  end,
}
