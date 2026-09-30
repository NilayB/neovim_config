return {
    -- add gruvbox colorscheme
    { "ellisonleao/gruvbox.nvim" },

    -- add koda colorscheme
    {
        "oskarnurm/koda.nvim",
        lazy = false, -- make sure to load this during startup if it main colorscheme
        config = function()
            -- require("koda").setup({ transparent = true })
            vim.cmd("colorscheme koda")
        end,
    },
}
