local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local terraform_doc = require("telescope._extensions.terraform_doc.builtin")
local setup = require("telescope._extensions.terraform_doc.config").setup

return telescope.register_extension({
  setup = setup,
  exports = {
    terraform_doc = terraform_doc.search,
    modules = terraform_doc.modules,
  },
})
