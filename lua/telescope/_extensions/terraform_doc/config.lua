local M = {
  opts = {
    url_open_command = "open",
    version = "latest",
    latest_provider_symbol = "*",
  },
}

M.setup = function(opts)
  M.opts.url_open_command = opts.url_open_command or M.opts.url_open_command
  M.opts.latest_provider_symbol = opts.latest_provider_symbol or M.opts.latest_provider_symbol
end

return M
