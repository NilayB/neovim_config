return {
    "folke/snacks.nvim",
    opts = {
        picker = {
            hidden = true,

            icons = {
                tree = {vertical = "  ", middle   = "  ", last     = "  ",},
            },

            sources = {
                explorer = {
                    hidden = true,
                    ignored = true,
                    layout = {
                        layout = { position = "right" },
                    },

                    format = function(item, picker)
                        local ret = Snacks.picker.format.file(item, picker)
                        local ok, err = pcall(function()
                        local name = vim.fn.fnamemodify(item.file, ":t")
                        for i = 2, #ret do
                            if ret[i][1] == name and ret[i - 1].virtual then
                            local icon = ret[i - 1]
                            if item.dir then
                                local chevron = vim.fn.nr2char(item.open and 0xF0140 or 0xF0142) -- chevron down / right
                                local folder  = vim.fn.nr2char(item.open and 0xF0770 or 0xF024B) -- folder open / closed
                                icon[1] = chevron .. " " .. folder .. " "
                            else
                                icon[1] = "  " .. icon[1] -- align files under folder names
                            end
                            break
                            end
                        end
                        end)
                        if not ok then
                        vim.notify_once("explorer format error: " .. tostring(err), vim.log.levels.ERROR)
                        end
                        return ret
                    end,
                },
            },
        },
    },
}
