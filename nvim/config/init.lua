-- load remap keys setting 1st to avoid leader key conflict
require("config.remap")

-- enable package manager
-- plugin list/config in $HOME/.config/nvim/lua/plugins/*.lua
require("config.lazy")

-- load autocommand
require("config.autocmd")

--load basic neovim option
require("config.option")

-- load custom script
require("config.verilog_convert")
require("config.script")


