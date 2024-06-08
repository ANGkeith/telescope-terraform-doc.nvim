local M = {
  opts = {
    latest_provider_symbol = "*",
    version = "latest",
    wincmd = "botright vnew",
    wrap = "nowrap",
  },
}

M.setup = function(opts)
  M.opts.latest_provider_symbol = opts.latest_provider_symbol or M.opts.latest_provider_symbol
  M.opts.wincmd = opts.wincmd or M.opts.wincmd
  M.opts.wrap = opts.wrap or M.opts.wrap
end

return M
