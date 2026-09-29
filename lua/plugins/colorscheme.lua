return {
    -- add gruvbox
    { "ellisonleao/gruvbox.nvim" },
    { "oskarnurm/koda.nvim" },

    -- Configure LazyVim to load gruvbox
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "gruvbox",
        },
    }
}
