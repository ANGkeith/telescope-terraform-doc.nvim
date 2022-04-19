local entry_display = require("telescope.pickers.entry_display")
local M = {}

function M.gen_from_run(opts)
  opts = opts or {}
  local name = vim.split(opts.full_name, "/")[2]

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 60 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.title,
      entry.category,
    })
  end

  return function(entry)
    local result = {
      id = entry.id,
      ordinal = entry.attributes.title,
      category = entry.attributes.category,
      title = entry.attributes.title,
      slug = entry.attributes.slug,
      display = make_display,
    }

    if entry.attributes.category == "data-sources" or entry.attributes.category == "resources" then
      result.title = name .. "_" .. entry.attributes.title
      result.ordinal = name .. "_" .. entry.attributes.title
    end

    return result
  end
end

function M.gen_from_providers(opts)
  opts = opts or {}

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 20 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.name,
      entry.description,
    })
  end
  return function(entry)
    return {
      ordinal = entry.name,
      name = entry.name,
      full_name = entry.full_name,
      description = entry.description,
      display = make_display,
    }
  end
end

function M.gen_from_modules(opts)
  opts = opts or {}

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = 40 },
      { width = 10 },
      { remaining = true },
    },
  })

  local make_display = function(entry)
    return displayer({
      entry.full_name,
      entry.provider_name,
      entry.description,
    })
  end
  return function(entry)
    local full_name = entry.namespace .. "/" .. entry.name
    return {
      ordinal = full_name .. entry.description,
      full_name = full_name,
      provider_name = entry.provider_name,
      description = entry.description,
      display = make_display,
    }
  end
end

return M
