local curl = require("plenary.curl")

local M = {}
if not vim.g.terraform_doc_git_namespace then
  vim.g.terraform_doc_git_namespace = "ANGkeith"
end

local base_url = "https://raw.githubusercontent.com/"
  .. vim.g.terraform_doc_git_namespace
  .. "/telescope-terraform-doc.nvim/api"

---
---Returns the url to the documentation
function M.get_modules()
  local result = {}
  local modules = curl.request({
    url = base_url .. "/modules.csv",
    method = "get",
  }).body

  for m in modules:gmatch("[^\n]+") do
    -- matches https://github.com/ANGkeith/telescope-terraform-doc.nvim/blob/3a9f9b3cea108876296e78f5ceaa34de79c64259/scripts/scrape.go#L160-L166
    local name, namespace, id, provider_name, source, description = m:match(string.rep("%s*(.-),", 5) .. "%s*(.*)")
    result[#result + 1] = {
      name = name,
      namespace = namespace,
      provider_name = provider_name,
      description = description:gsub('"', ""),
      source = source,
      id = id,
    }
  end
  return result
end

return M
