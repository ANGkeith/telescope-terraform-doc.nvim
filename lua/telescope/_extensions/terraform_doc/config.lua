local function open(url)
  if vim.fn.has("mac") == 1 then
    vim.fn.system('open "' .. url .. '"')
  elseif vim.fn.has("unix") == 1 then
    vim.fn.system('xdg-open "' .. url .. '"')
  elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    vim.fn.system('start "" "' .. url .. '"')
  end
end

local default_opts = {
  latest_provider_symbol = "*",
  version = "latest",
  wincmd = "botright vnew",
  wrap = "nowrap",
  url_open_handler = vim.ui.open or open,
}
local M = {}

M.setup = function(opts)
  M._opts = vim.tbl_extend("keep", opts or {}, default_opts)
end

M.opts = function()
  return M._opts
end

return M
