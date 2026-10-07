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
    end,

    config = function(_, opts)
        local dap, dapui = require("dap"), require("dapui")
        dapui.setup(opts)

        local saved
        local function snapshot()
            saved = {}
            for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                saved[w] = {
                    width = vim.api.nvim_win_get_width(w),
                    height = vim.api.nvim_win_get_height(w),
                }
            end
        end

        local function restore()
            local snap = saved
            if not snap then return end
            -- dapui closes its windows asynchronously, so wait a beat
            vim.defer_fn(function()
                for w, size in pairs(snap) do
                    if vim.api.nvim_win_is_valid(w) then
                        pcall(vim.api.nvim_win_set_width, w, size.width)
                        pcall(vim.api.nvim_win_set_height, w, size.height)
                    end
                end
            end, 50)
        end

        -- snapshot BEFORE dapui opens, restore AFTER it closes
        dap.listeners.before.event_initialized["layout_snapshot"] = snapshot
        dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({}) end
        dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close({}) end
        dap.listeners.before.event_exited["dapui_config"] = function() dapui.close({}) end
        dap.listeners.after.event_terminated["layout_restore"] = restore
        dap.listeners.after.event_exited["layout_restore"] = restore
    end,
}
