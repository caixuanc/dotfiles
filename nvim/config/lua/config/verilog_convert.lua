-- Verilog base converters:
--   8'b1010 <-> 8'd10 <-> 8'ha
-- Commands: Bin2dec, Dec2bin, Dec2hex, Hex2dec, Hex2bin, Bin2hex

local function is_visual_char_or_block()
  local last = vim.fn.histget(':', -1)
  local vmode = vim.fn.visualmode()
  return last:match("^'<,'>") ~= nil and vmode ~= 'V'
end

local function strip_us(s)
  return (s:gsub('_', ''))
end

local base_letter = { [2] = 'b', [10] = 'd', [16] = 'h' }
local base_pat = {
  [2]  = [[\([01_]\+\)]],
  [10] = [[\([0-9_]\+\)]],
  [16] = [[\([0-9a-fA-F_]\+\)]],
}

local base_char = {
  [2]  = [[\[bB\]],
  [10] = [[\[dD\]],
  [16] = [[\[hH\]],
}

--- Build a range substitute: WIDTH'FROM digits -> WIDTH'TO value
--- from_base / to_base: 2, 10, or 16
local function make_subst(from_base, to_base, visual)
  local fmt
  if to_base == 16 then
    fmt = [[printf("%%x",str2nr(substitute(submatch(2),"_","","g"),%d))]]
  elseif to_base == 2 then
    -- Vim has no %b; build binary manually
    fmt = [[substitute(printf("%%b",str2nr(substitute(submatch(2),"_","","g"),%d)),"^0\\+","","")]]
    -- Note: printf %%b is NOT in Vim. Use custom expression instead — see below.
  else
    fmt = [[str2nr(substitute(submatch(2),"_","","g"),%d)]]
  end

  -- Binary output needs a helper; use Lua callback path for reliability.
  -- For Vim expr: only use str2nr + printf for dec/hex; binary via v:lua.
  local prefix = visual and [[s/\%V]] or [[s/]]
  local from_c = ({ [2] = '[bB]', [10] = '[dD]', [16] = '[hH]' })[from_base]
  local to_c = base_letter[to_base]

  if to_base == 2 then
    -- Call Lua to format binary
    return string.format(
      [[%s\(\d*\)'%s\([01_0-9a-fA-F]\+\)/\=submatch(1)."'%s".v:lua.require('verilog_base')._fmt(str2nr(substitute(submatch(2),"_","","g"),%d),2)/g]],
      prefix, from_c, to_c, from_base
    ):gsub('%[01_0%-9a%-fA%-F%]', function()
      -- fix digit class per from_base
      return nil
    end)
  end

  local digits = ({ [2] = '[01_]', [10] = '[0-9_]', [16] = '[0-9a-fA-F_]' })[from_base]
  local value_expr
  if to_base == 16 then
    value_expr = string.format(
      [[printf("%%x",str2nr(substitute(submatch(2),"_","","g"),%d))]],
      from_base
    )
  else
    value_expr = string.format(
      [[str2nr(substitute(submatch(2),"_","","g"),%d)]],
      from_base
    )
  end

  return string.format(
    [[%s\(\d*\)'%s\(%s\+\)/\=submatch(1)."'%s".%s/g]],
    prefix, from_c, digits, to_c, value_expr
  )
end

-- Simpler, fully Lua-driven implementation (recommended)
local M = {}

function M._fmt(n, base)
  if n == nil then return '' end
  if base == 16 then
    return string.format('%x', n)
  elseif base == 2 then
    if n == 0 then return '0' end
    local t = {}
    while n > 0 do
      table.insert(t, 1, n % 2)
      n = math.floor(n / 2)
    end
    return table.concat(t)
  else
    return tostring(n)
  end
end

local function parse_verilog(s, expect_base)
  -- WIDTH'base digits  or  'base digits
  local width, bchar, digits = s:match("^(%d*)'([bBdDhH])([0-9a-fA-F_]+)$")
  if not digits then return nil end
  local base = ({ b = 2, B = 2, d = 10, D = 10, h = 16, H = 16 })[bchar]
  if expect_base and base ~= expect_base then return nil end
  local n = tonumber(strip_us(digits), base)
  if not n then return nil end
  return width, n
end

local function format_verilog(width, n, to_base)
  local body = M._fmt(n, to_base)
  local letter = base_letter[to_base]
  if width and width ~= '' then
    return string.format("%s'%s%s", width, letter, body)
  end
  return string.format("'%s%s", letter, body)
end

local function convert_arg(arg, from_base, to_base)
  local width, n = parse_verilog(arg, from_base)
  if not n then
    -- bare number in from_base
    n = tonumber(strip_us(arg), from_base)
    if not n then return nil end
    return M._fmt(n, to_base)
  end
  return format_verilog(width, n, to_base)
end

--- Replace all WIDTH'from… on lines with WIDTH'to…
local function convert_range(line1, line2, from_base, to_base)
  local from_c = ({ [2] = '[bB]', [10] = '[dD]', [16] = '[hH]' })[from_base]
  local digits = ({ [2] = '[01_]', [10] = '[0-9_]', [16] = '[0-9a-fA-F_]' })[from_base]
  local to_c = base_letter[to_base]
  local visual = is_visual_char_or_block()
  local prefix = visual and [[s/\%V]] or [[s/]]

  -- Use \= with v:lua for all bases (binary-safe)
  local pat = string.format(
    [[%s\(\d*\)'%s\(%s\+\)/\=submatch(1)."'%s".v:lua.require('verilog_base')._fmt(str2nr(substitute(submatch(2),"_","","g"),%d),%d)/g]],
    prefix, from_c, digits, to_c, from_base, to_base
  )

  local ok, err = pcall(vim.cmd, string.format('%d,%d%s', line1, line2, pat))
  -- substitute leaves the pattern in hlsearch; clear it
  vim.cmd('nohlsearch')
  return ok, err
end

local function make_cmd(from_base, to_base, err_msg)
  return function(opts)
    local arg = opts.args
    if arg == nil or arg == '' then
      local ok = convert_range(opts.line1, opts.line2, from_base, to_base)
      if not ok then
        vim.notify(err_msg, vim.log.levels.ERROR)
      end
    else
      local out = convert_arg(arg, from_base, to_base)
      if out then
        print(out)
      else
        vim.notify('Error: invalid literal: ' .. arg, vim.log.levels.ERROR)
      end
    end
  end
end

-- Register module for v:lua.require('verilog_base')
package.loaded['verilog_base'] = M

vim.api.nvim_create_user_command('Bin2dec', make_cmd(2, 10, "Error: No Verilog binary (e.g. 8'b1010) found"), { nargs = '?', range = true })
vim.api.nvim_create_user_command('Dec2bin', make_cmd(10, 2, "Error: No Verilog decimal (e.g. 8'd10) found"), { nargs = '?', range = true })
vim.api.nvim_create_user_command('Dec2hex', make_cmd(10, 16, "Error: No Verilog decimal (e.g. 8'd10) found"), { nargs = '?', range = true })
vim.api.nvim_create_user_command('Hex2dec', make_cmd(16, 10, "Error: No Verilog hex (e.g. 8'hff) found"), { nargs = '?', range = true })
vim.api.nvim_create_user_command('Hex2bin', make_cmd(16, 2, "Error: No Verilog hex (e.g. 8'hff) found"), { nargs = '?', range = true })
vim.api.nvim_create_user_command('Bin2hex', make_cmd(2, 16, "Error: No Verilog binary (e.g. 8'b1010) found"), { nargs = '?', range = true })

-- Hex -> Dec (Verilog): <leader>chd
vim.keymap.set({ "n", "x" }, "<leader>chd", ":Hex2dec<CR>", { silent = true, desc = "Convert Verilog hex to decimal (8'hff -> 8'd255)" })
vim.keymap.set({ "n", "x" }, "<leader>cdh", ":Dec2hex<CR>", { silent = true, desc = "Convert Verilog decimal to hex (8'd255 -> 8'hff)" })

return M
