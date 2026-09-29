-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable single-line automatic comment.
-- Disable automatic adding comment symbols on the next line after a line comment
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- 1. Ensure 'r' and 'o' are enabled globally so block comments work
    vim.opt_local.formatoptions:append({ "r", "o" })

    -- (Optional) Disable auto-wrapping text
    vim.opt_local.formatoptions:remove({ "c" })

    -- 2. Read the current language's comment formatting rules
    local current_comments = vim.bo.comments
    local new_comments = {}

    -- 3. Parse the comma-separated list of comment rules
    for part in string.gmatch(current_comments, "([^,]+)") do
      -- Split the rule into its flags (before the colon) and the symbol (after)
      local flags, symbol = string.match(part, "^([^:]*):(.*)$")

      if flags and symbol then
        -- If the flags do NOT contain 's', 'm', or 'e', it is a single-line comment
        if not string.match(flags, "[sme]") then
          -- If it doesn't already have the 'f' (first-line) flag, add it
          if not string.match(flags, "f") then
            flags = flags .. "f"
          end
        end
        -- Reconstruct the rule
        table.insert(new_comments, flags .. ":" .. symbol)
      else
        -- Fallback for badly formatted rules
        table.insert(new_comments, part)
      end
    end

    -- 4. Apply the modified rules back to the buffer
    vim.bo.comments = table.concat(new_comments, ",")
  end,
  desc = "Universally disable auto-continuation for single-line comments",
})
-- Diable single-line automatic comment block end
