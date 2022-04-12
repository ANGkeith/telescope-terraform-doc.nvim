" Use `.vim extension` to ensure that this file is loaded first

lua <<EOF
vim.g.terraform_doc_root_git_dir = vim.fn.expand("<sfile>:h:h")

local function exec(command)
  local f = io.popen(command)
  local stdout = f:read("*a")
  f:close()
  return stdout
end
local git_origin_url = exec("cd " .. vim.g.terraform_doc_root_git_dir .. " && git remote get-url origin | tr -d '\n'")

vim.g.terraform_doc_git_namespace = git_origin_url:match("https://[^/]+/(.*)/.*")
EOF
