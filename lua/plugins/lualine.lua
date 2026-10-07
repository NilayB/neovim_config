return {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
        table.insert(opts.sections.lualine_x, {
            "encoding",
            fmt = string.upper, -- UTF-8 instead of utf-8
        })

        local icon = vim.fn.nr2char

        table.insert(opts.sections.lualine_x, {
            "fileformat",
            symbols = {
                -- unix = icon(0xf303) .. " LF",   -- Arch logo
                unix = icon(0xf17c) .. " LF",   -- Tux
                dos  = icon(0xf17a) .. " CRLF", -- Windows logo
                mac  = icon(0xf179) .. " CR",   -- Apple logo
            },
        })

        -- Fallback for section B outside git repos: show the folder name
        table.insert(opts.sections.lualine_b, {
        function()
            return vim.fn.nr2char(0xf07b) .. " " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end,
        cond = function()
            return vim.b.gitsigns_head == nil
        end,
        })
    end,
}
