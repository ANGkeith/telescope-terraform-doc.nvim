local M_opts = require("telescope._extensions.terraform_doc.config").opts
local curl = require("plenary.curl")

local M = {}
local base_url = "https://registry.terraform.io"

---
---Returns provider version id
function M.get_provider_versions_id(full_name)
  local tmp = vim.split(full_name, "/")
  local namespace = tmp[1]
  local name = tmp[2]
  local resp = vim.fn.json_decode(curl.request({
    -- https://registry.terraform.io/v2/providers?filter[namespace]=hashicorp&filter[name]=aws
    url = base_url .. "/v2/providers?filter[namespace]=" .. namespace .. "&filter[name]=" .. name,
    method = "get",
    accept = "application/json",
  }).body)
  return resp.data[1].id
end

---
---Returns the metadata for the specified provider version
function M.get_provider_versions_id_meta(full_name, version)
  version = version or "latest"

  local provider_id = M.get_provider_versions_id(full_name)

  local resp = vim.fn.json_decode(curl.request({
    -- https://registry.terraform.io/v2/providers/323?include=provider-versions
    url = base_url .. "/v2/providers/" .. provider_id .. "?include=provider-versions",
    method = "get",
    accept = "application/json",
  }).body)

  -- I am assuming that the last element in `.data.relationships["provider-versions"].data` is the latest version
  local rel_data = resp.data.relationships["provider-versions"].data
  local latest_version_id = rel_data[#rel_data].id

  local version_ids = resp.included
  for _, v in pairs(version_ids) do
    if version == "latest" then
      if v.id == latest_version_id then
        return {
          id = v.id,
          latest = true,
          version = v.attributes.version,
          full_name = resp.data.attributes["full-name"],
        }
      end
    else
      if v.attributes.version == version then
        return {
          id = v.id,
          latest = v.id == latest_version_id,
          version = v.attributes.version,
          full_name = resp.data.attributes["full-name"],
        }
      end
    end
  end

  return error("version " .. version .. " not found")
end

---
---Returns prompt title
function M.gen_prompt_title(provider_version_meta)
  if provider_version_meta.latest then
    return provider_version_meta.full_name
      .. " (v"
      .. provider_version_meta.version
      .. ")"
      .. M_opts.latest_provider_symbol
  end
  return provider_version_meta.full_name .. " (v" .. provider_version_meta.version .. ")"
end

---
---Returns the list of resources and data-sources
function M.get_provider_resources(version_id)
  return vim.fn.json_decode(curl.request({
    -- https://registry.terraform.io/v2/provider-versions/20351?include=provider-docs
    url = base_url .. "/v2/provider-versions/" .. version_id .. "?include=provider-docs",
    method = "get",
    accept = "application/json",
  }).body).included
end

---
---Returns the url to the documentation
function M.get_docs_url(full_name, version, category, resource_slug)
  if category == "overview" then
    return base_url .. "/providers/" .. full_name .. "/" .. version .. "/docs"
  end
  return base_url .. "/providers/" .. full_name .. "/" .. version .. "/docs/" .. category .. "/" .. resource_slug
end

---
---Returns the list of offical providers
function M.get_official_providers()
  local official_providers = vim.fn.json_decode(curl.request({
    -- https://registry.terraform.io/v2/providers?filter[tier]=official&page[size]=100
    url = base_url .. "/v2/providers?filter[tier]=official&page[size]=100",
    method = "get",
    accept = "application/json",
  }).body).data
  for i, o in pairs(official_providers) do
    official_providers[i] = {}
    official_providers[i].full_name = o.attributes["full-name"]
    official_providers[i].name = o.attributes.name
    if o.attributes.description == "" then
      official_providers[i].description = "NA"
    else
      -- removes '\n' otherwise it can cause issue with pickers
      official_providers[i].description = string.gsub(o.attributes.description, "\n", ".")
    end
  end

  return official_providers
end

return M
