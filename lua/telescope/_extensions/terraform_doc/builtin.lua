local actions = require("telescope.actions")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

local M_actions = require("telescope._extensions.terraform_doc.actions")
local M_api = require("telescope._extensions.terraform_doc.api")
local M_local_api = require("telescope._extensions.terraform_doc.local_api")
local M_make_entry = require("telescope._extensions.terraform_doc.make_entry")
local M_opts = require("telescope._extensions.terraform_doc.config").opts

local M = {}

function M.search(opts)
  opts = vim.tbl_extend("keep", opts, M_opts)

  if not opts.full_name then
    M.providers(opts)
    return
  end

  local provider_version_meta = M_api.get_provider_versions_id_meta(opts.full_name, opts.version)

  pickers
    .new(opts, {
      prompt_title = M_api.gen_prompt_title(provider_version_meta),
      sorter = conf.generic_sorter(opts),
      finder = finders.new_table({
        results = M_api.get_provider_resources(provider_version_meta.id),
        entry_maker = M_make_entry.gen_from_run(opts),
      }),
      attach_mappings = function(_, map)
        actions.select_default:replace(M_actions.url_opener(opts))
        map("i", "<c-d>", M_actions.doc_view(opts))
        return true
      end,
    })
    :find()
end

function M.providers(opts)
  opts = vim.tbl_extend("keep", opts, M_opts)

  pickers
    .new(opts, {
      prompt_title = "Official Hashicorp Providers",
      sorter = conf.generic_sorter(opts),
      finder = finders.new_table({
        results = M_api.get_official_providers(),
        entry_maker = M_make_entry.gen_from_providers(opts),
      }),
      attach_mappings = function(_)
        actions.select_default:replace(M_actions.search_selected_providers(opts))
        return true
      end,
    })
    :find()
end

function M.modules(opts)
  opts = vim.tbl_extend("keep", opts, M_opts)

  pickers
    .new(opts, {
      prompt_title = "Terraform Modules",
      sorter = conf.generic_sorter(opts),
      finder = finders.new_table({
        results = M_local_api.get_modules(),
        entry_maker = M_make_entry.gen_from_modules(opts),
      }),
      attach_mappings = function(_)
        actions.select_default:replace(M_actions.url_opener_module(opts))
        return true
      end,
    })
    :find()
end

return M
