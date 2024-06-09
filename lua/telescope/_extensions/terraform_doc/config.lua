local M = {
  opts = {
    latest_provider_symbol = "*",
    version = "latest",
    wincmd = "botright vnew",
    wrap = "nowrap",
  },
}

local function open(url)
  if vim.fn.has("mac") == 1 then
    vim.fn.system('open "' .. url .. '"')
  elseif vim.fn.has("unix") == 1 then
    vim.fn.system('xdg-open "' .. url .. '"')
  elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    vim.fn.system('start "" "' .. url .. '"')
  end
end

M.setup = function(opts)
  M.opts.url_open_handler = opts.url_open_handler or vim.ui.open or open
  M.opts.latest_provider_symbol = opts.latest_provider_symbol or M.opts.latest_provider_symbol
  M.opts.wincmd = opts.wincmd or M.opts.wincmd
  M.opts.wrap = opts.wrap or M.opts.wrap
end

return M
