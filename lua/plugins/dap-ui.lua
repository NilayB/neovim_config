return {
    "rcarriga/nvim-dap-ui",
    dependencies = {
        "mfussenegger/nvim-dap",
    },

    --opts = {
    --    controls = {enabled = false},
    --},

    init = function()
        local titles = {
            dapui_scopes      = "  Scopes",
            dapui_breakpoints = "  Breakpoints",
            dapui_watches     = " 󰂥 Watches",
            dapui_console     = "  Console",
            dapui_stacks      = "  Stack Trace",
            ["dap-repl"]      = "  REPL",
        }

        vim.api.nvim_create_autocmd("FileType", {
            pattern = vim.tbl_keys(titles),
            callback = function(ev)
                -- schedule so dap-ui has finished placing the buffer in its window
                vim.schedule(function()
                    for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
                        vim.wo[win].winbar = "%#Title# " .. titles[ev.match]
                    end
                end)
            end,
        })
    end
}
