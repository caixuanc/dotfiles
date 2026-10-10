return {
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.3", -- lastest that still supports Neovim 0.9
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- remove verilog to not keep check verilog installed on every startup
        ensure_installed = { "lua", "vim", "vimdoc", "query", "bash", "tcl" },
        highlight = { 
            enable = true, 
            disable = function(lang, buf)
                if lang == "verilog" then return true end
                -- local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                -- return ok and stats and stats.size > 400 * 2048 -- disable if >200KB
            end,
        },
      })
    end,
  },
}
