local M_api = require("telescope._extensions.terraform_doc.api")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

local M = {}

function M.url_opener(opts)
  return function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)

    local url = M_api.get_docs_url(opts.full_name, opts.version, selection.category, selection.slug)
    os.execute(string.format('%s "%s"', opts.url_open_command, url))
  end
end

function M.doc_view(opts)
  return function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)

    local content = M_api.get_docs_content(selection.id)
    vim.api.nvim_command(opts.wincmd)

    local buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_name(0, selection.category .. " " .. selection.title)

    vim.api.nvim_buf_set_option(0, "buftype", "nofile")
    vim.api.nvim_buf_set_option(0, "swapfile", false)
    vim.api.nvim_buf_set_option(0, "filetype", "markdown")
    vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
    vim.api.nvim_command("setlocal wrap")
    vim.api.nvim_command("setlocal cursorline")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  end
end

function M.url_opener_module(opts)
  return function(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    local url = M_api.get_docs_url_module(selection.full_name, selection.provider_name)
    os.execute(string.format('%s "%s"', opts.url_open_command, url))
  end
end

function M.search_selected_providers(opts)
  return function()
    local selection = action_state.get_selected_entry()
    opts.full_name = selection.full_name

    require("telescope._extensions.terraform_doc.builtin").search(opts)
  end
end

return M
