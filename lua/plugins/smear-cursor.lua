return {
    {
        "sphamba/smear-cursor.nvim",

        config = function()
            require("smear_cursor").setup({
                never_draw_over_target = true,
                smear_insert_mode = false,
                min_vertical_distance_smear = 2,
                min_horizontal_distance_smear = 2,

                time_interval = 12, --ms
                stiffness = 0.85,
                trailing_stiffness = 0.5,
                damping = 0.92, -- stops bouncing

                distance_stop_animating = 0.5
            })
        end,
    },
}
