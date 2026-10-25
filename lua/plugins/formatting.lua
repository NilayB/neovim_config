-- Default style: "allman" (Visual Studio-like) or "kr" (CLion-like)
vim.g.c_style = vim.g.c_style or "allman"

local common = "IndentWidth: 4, TabWidth: 4, UseTab: Never, ColumnLimit: 0, "
  .. "AccessModifierOffset: -4, PointerAlignment: Left, ReflowComments: false, "
  .. "Cpp11BracedListStyle: false"

local styles = {
  allman = "{BasedOnStyle: Microsoft, " .. common .. "}",
  kr = "{BasedOnStyle: LLVM, BreakBeforeBraces: Attach, " .. common .. "}",
}

vim.api.nvim_create_user_command("CStyle", function(o)
  local arg = o.args
  if arg == "" or arg == "toggle" then
    arg = vim.g.c_style == "allman" and "kr" or "allman"
  end
  if not styles[arg] then
    vim.notify("CStyle: use allman, kr or toggle", vim.log.levels.ERROR)
    return
  end
  vim.g.c_style = arg
  vim.notify("C style: " .. arg)
end, {
  nargs = "?",
  complete = function() return { "allman", "kr", "toggle" } end,
})

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
    formatters = {
      ["clang-format"] = {
        prepend_args = function(_, ctx)
          -- A project's own .clang-format always wins
          if vim.fs.find({ ".clang-format", "_clang-format" }, { upward = true, path = ctx.dirname })[1] then
            return {}
          end
          return { "--style=" .. styles[vim.g.c_style] }
        end,
      },
    },
  },
}
