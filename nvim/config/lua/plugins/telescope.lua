return {
    {
        "nvim-telescope/telescope.nvim", 
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require("telescope").setup{
                --  All the info you're looking for is in `:help telescope.setup()`
                defaults = {
                    mappings = {
                        i = {
                            ["<C-u>"] = false,
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        },
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                        no_ignore = true,
                    },
                }
            }

            -- set keymaps
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
            vim.keymap.set('n', '<leader>fp', builtin.git_files, { desc = 'Telescope find git repo files' })
            --vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
            vim.keymap.set('n', '<leader>ev', function()
                require('telescope.builtin').find_files{
                    cwd = vim.fn.stdpath("config")
                }
            end, { desc = 'Telescope find nvim config' })
    end,
    }
}
