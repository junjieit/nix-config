local ensure_installed = {
    "bash",
    "c",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
}

local selection_stacks = {}

local function select_node(node)
    local start_row, start_col, end_row, end_col = node:range()

    -- Tree-sitter ranges have an exclusive end position; Visual mode does not.
    if end_col == 0 and end_row > start_row then
        end_row = end_row - 1
        end_col = #vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1]
    end

    vim.cmd("normal! <Esc>")
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
    vim.cmd("normal! v")
    vim.api.nvim_win_set_cursor(0, { end_row + 1, math.max(end_col - 1, 0) })
end

local function start_selection()
    local node = vim.treesitter.get_node()
    if not node then
        return
    end

    selection_stacks[vim.api.nvim_get_current_buf()] = { node }
    select_node(node)
end

local function increment_selection()
    local bufnr = vim.api.nvim_get_current_buf()
    local stack = selection_stacks[bufnr]
    if not stack or #stack == 0 then
        start_selection()
        return
    end

    local parent = stack[#stack]:parent()
    if parent then
        table.insert(stack, parent)
        select_node(parent)
    end
end

local function decrement_selection()
    local stack = selection_stacks[vim.api.nvim_get_current_buf()]
    if not stack or #stack <= 1 then
        return
    end

    table.remove(stack)
    select_node(stack[#stack])
end

local function textobject_move(method, capture)
    return function()
        require("nvim-treesitter-textobjects.move")[method](capture, "textobjects")
    end
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                branch = "main",
            },
        },
        config = function()
            local treesitter = require("nvim-treesitter")
            treesitter.setup()
            treesitter.install(ensure_installed)

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter-enable", { clear = true }),
                callback = function()
                    if pcall(vim.treesitter.start) then
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })

            require("nvim-treesitter-textobjects").setup({
                move = { set_jumps = true },
            })
        end,
        cmd = { "TSInstall", "TSUpdate", "TSUninstall" },
        keys = {
            { "<C-Space>", start_selection, desc = "Start Treesitter Selection" },
            { "<C-Space>", increment_selection, mode = "x", desc = "Increment Treesitter Selection" },
            { "<BS>", decrement_selection, mode = "x", desc = "Decrement Treesitter Selection" },
            { "]f", textobject_move("goto_next_start", "@function.outer"), desc = "Next Function Start" },
            { "]F", textobject_move("goto_next_end", "@function.outer"), desc = "Next Function End" },
            { "[f", textobject_move("goto_previous_start", "@function.outer"), desc = "Previous Function Start" },
            { "[F", textobject_move("goto_previous_end", "@function.outer"), desc = "Previous Function End" },
            { "]c", textobject_move("goto_next_start", "@class.outer"), desc = "Next Class Start" },
            { "]C", textobject_move("goto_next_end", "@class.outer"), desc = "Next Class End" },
            { "[c", textobject_move("goto_previous_start", "@class.outer"), desc = "Previous Class Start" },
            { "[C", textobject_move("goto_previous_end", "@class.outer"), desc = "Previous Class End" },
            { "]a", textobject_move("goto_next_start", "@parameter.inner"), desc = "Next Parameter" },
            { "]A", textobject_move("goto_next_end", "@parameter.inner"), desc = "Next Parameter End" },
            { "[a", textobject_move("goto_previous_start", "@parameter.inner"), desc = "Previous Parameter" },
            { "[A", textobject_move("goto_previous_end", "@parameter.inner"), desc = "Previous Parameter End" },
        },
    },
    {
        "windwp/nvim-ts-autotag",
        dependencies = "nvim-treesitter/nvim-treesitter",
        opts = {},
        event = "VeryLazy",
    },
}
