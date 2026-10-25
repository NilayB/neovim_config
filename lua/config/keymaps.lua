-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.keymap.set("c", "<C-BS>", "<C-w>")
vim.keymap.set("i", "<C-H>", "<C-w>")
vim.keymap.set("c", "<C-H>", "<C-w>")

-- Format the current line when typing ; or }
local function in_comment()
  local line = vim.api.nvim_get_current_line()
  if line:match("^%s*//") or line:match("^%s*/?%*") then
    return true
  end
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local ok, node = pcall(vim.treesitter.get_node, { pos = { row - 1, math.max(col - 2, 0) } })
  return ok and node ~= nil and node:type():find("comment") ~= nil
end

local function open_parens()
  local line = vim.api.nvim_get_current_line()
  local _, o = line:gsub("%(", "")
  local _, c = line:gsub("%)", "")
  return o > c
end

local function is_c()
  return vim.tbl_contains({ "c", "cpp" }, vim.bo.filetype)
end

local function format_range(l1, l2)
  require("conform").format({
    formatters = { "clang-format" },
    lsp_format = "never",
    range = { start = { l1, 0 }, ["end"] = { l2, #vim.fn.getline(l2) } },
    quiet = true,
  })
end

-- `;` -> format the current statement (skipped inside open parens, e.g. for(;;))
local function format_line()
  if not is_c() or in_comment() or open_parens() then return end
  local l = vim.fn.line(".")
  format_range(l, l)
end


vim.keymap.set("i", ";", function()
  vim.api.nvim_feedkeys(";", "n", false)
  vim.schedule(format_line)
end)
