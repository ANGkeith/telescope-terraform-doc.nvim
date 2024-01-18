local M = {
  opts = {
    url_open_command = vim.fn.has("macunix") and "open" or "xdg-open",
    latest_provider_symbol = "*",
    version = "latest",
    wincmd = "botright vnew",
    wrap = "nowrap",
  },
}

M.setup = function(opts)
  M.opts.url_open_command = opts.url_open_command or M.opts.url_open_command
  M.opts.latest_provider_symbol = opts.latest_provider_symbol or M.opts.latest_provider_symbol
  M.opts.wincmd = opts.wincmd or M.opts.wincmd
  M.opts.wrap = opts.wrap or M.opts.wrap
end

return M
