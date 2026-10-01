return {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
        table.insert(opts.sections.lualine_x, {
            "encoding",
            fmt = string.upper, -- UTF-8 instead of utf-8
        })
        table.insert(opts.sections.lualine_x, {
            "fileformat",
            symbols = { unix = "LF", dos = "CRLF", mac = "CR" },
        })
    end,
}
