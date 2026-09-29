return {
    {
        "Civitasv/cmake-tools.nvim",
        dependencies = {"nvim-lua/plenary.nvim"},

        opts = {
            cmake_build_directory = "out/${variant:buildType}",
        },

        keys = {
            {"<leader>m", group = "CMake"},

            {"<leader>mg", "<cmd>CMakeGenerate<cr>", desc = "Generate"},
            {"<leader>mb", "<cmd>CMakeBuild<cr>", desc = "Build"},
            {"<leader>mr", "<cmd>CMakeRun<cr>", desc = "Run"},
            {"<leader>md", "<cmd>CMakeDebug<cr>", desc = "Debug"},
            {"<leader>ms", "<cmd>CMakeSelectBuildType<cr>", desc = "Select Build Type"},
            {"<leader>mt", "<cmd>CMakeSelectBuildTarget<cr>", desc = "Select Target"},
            {"<leader>mo", "<cmd>CMakeOpenExecutor<cr>", desc = "Open Console"},
            {"<leader>ml", "<cmd>CMakeCloseExecutor<cr>", desc = "Close Console"},
        },
    },
}
