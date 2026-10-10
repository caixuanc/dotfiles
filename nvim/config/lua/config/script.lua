-- Function to prettify XML
local function do_pretty_xml()
  vim.cmd("silent %!xmllint --format %")
end
vim.api.nvim_create_user_command("Xmlpp", do_pretty_xml, {
  desc = "Pretty-print XML with xmllint",
})

