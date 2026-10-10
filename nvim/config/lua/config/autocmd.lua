---------------------------------------------------------
-- Auto Commands
---------------------------------------------------------
local augroup = vim.api.nvim_create_augroup("UserAutoCmds", { clear = true })

-- Clear suffixesadd to make sure native filetype has higher priority.
vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
  group = augroup,
  pattern = "*.bcm.xml",
  callback = function()
    vim.opt_local.suffixesadd:remove(".bcm.xml")
    vim.opt_local.suffixesadd:prepend(".bcm.xml")
    vim.opt_local.suffixesadd:append(".rbc.sv")
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
  group = augroup,
  pattern = "*.rbc.sv",
  callback = function()
    vim.opt_local.suffixesadd:remove(".rbc.sv")
    vim.opt_local.suffixesadd:prepend(".rbc.sv")
    vim.opt_local.suffixesadd:append(".bcm.xml")
  end,
})

-- Search BCMRBC of other variants when using 'gf'
vim.api.nvim_create_autocmd("BufRead", {
  group = augroup,
  pattern = { "*.bcm.xml", "*.rbc.sv" },
  callback = function()
    vim.opt_local.path:append("../../*/bcmrbc/")
  end,
})

-- Jump to other verilog
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "verilog",
  callback = function()
    vim.opt_local.suffixesadd = { ".v", ".sv" }
    vim.opt_local.path:append("../../../*/rtl/block_function/**2")
    vim.opt_local.path:append("../../../*/rtl/wrappers/")
    -- KM cheetah structure
    vim.opt_local.path:append("../../*/block_function/**2")
  end,
})

-- Jump to other systemverilog
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "systemverilog",
  callback = function()
    vim.opt_local.suffixesadd = { ".sv", ".v" }
    vim.opt_local.path:append("../../../*/rtl/block_function/**2")
    -- KM cheetah structure
    vim.opt_local.path:append("../../*/block_function/**2")
  end,
})

-- Jump to other verilog_systemverilog
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "verilog_systemverilog",
  callback = function()
    vim.opt_local.suffixesadd = { ".v", ".sv" }
    vim.opt_local.path:append("../../../*/rtl/block_function/**2")
    -- KM cheetah structure
    vim.opt_local.path:append("../../*/block_function/**2")
    vim.opt_local.path:append("../../../../subip/*/*/src/rtl/**2")
  end,
})
