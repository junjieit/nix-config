return {
    {
        "folke/snacks.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            input = {},
            picker = {},
            terminal = {}
        }
    },
    {
        "NickvanDyke/opencode.nvim",
        dependencies = {"folke/snacks.nvim"},
        config = function()
            ---@type opencode.Opts
            vim.g.opencode_opts = {
                -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
            }

            -- Required for `opts.events.reload`.
            vim.o.autoread = true

            -- Recommended/example keymaps.
            vim.keymap.set({"n", "x"}, "<C-a>", function()
                require("opencode").ask("@this: ", {
                    submit = true
                })
            end, {
                desc = "Ask opencode"
            })
            vim.keymap.set({"n", "x"}, "<C-x>", function()
                require("opencode").select()
            end, {
                desc = "Execute opencode action…"
            })
            vim.keymap.set({"n", "x"}, "ga", function()
                require("opencode").prompt("@this")
            end, {
                desc = "Add to opencode"
            })
            vim.keymap.set({"n", "t"}, "<C-.>", function()
                require("opencode").toggle()
            end, {
                desc = "Toggle opencode"
            })
            vim.keymap.set("n", "<S-C-u>", function()
                require("opencode").command("session.half.page.up")
            end, {
                desc = "opencode half page up"
            })
            vim.keymap.set("n", "<S-C-d>", function()
                require("opencode").command("session.half.page.down")
            end, {
                desc = "opencode half page down"
            })
            -- Preserve the built-in increment/decrement commands after mapping Ctrl-A/Ctrl-X to OpenCode.
            vim.keymap.set('n', '+', '<C-a>', {
                desc = 'Increment',
                noremap = true
            })
            vim.keymap.set('n', '-', '<C-x>', {
                desc = 'Decrement',
                noremap = true
            })
        end
    }
}
