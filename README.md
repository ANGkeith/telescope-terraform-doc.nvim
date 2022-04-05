[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/ANGkeith/telescope-terraform-doc.nvim/main.svg)](https://results.pre-commit.ci/latest/github/ANGkeith/telescope-terraform-doc.nvim/main)

# telescope-terraform-doc.nvim

`telescope-terraform-doc.nvim` is an extension for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) that provides its users with ability to search and browse terraform providers docs.

## Demo
![](./media/demo.gif)

## Installation
### vim-plug
```viml
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'ANGkeith/telescope-terraform-doc.nvim'
```
## Setup
Add the following to your `init.vim`:
``` lua
require('telescope').load_extension('terraform_doc')
```

## Usage
Browse the official hashicorp providers:
```vim
:Telescope terraform_doc
```

Browse resources from the latest `hashicorp/aws` provider:
```vim
:Telescope terraform_doc full_name=hashicorp/aws
```

Browse resources from the v3.74.0 `hashicorp/aws` provider:
```vim
:Telescope terraform_doc full_name=hashicorp/aws version=3.74.0
```

### Keymap ideas
```vim
nnoremap <space>ott :Telescope terraform_doc<cr>
nnoremap <space>ota :Telescope terraform_doc full_name=hashicorp/aws<cr>
nnoremap <space>otg :Telescope terraform_doc full_name=hashicorp/google<cr>
nnoremap <space>otk :Telescope terraform_doc full_name=hashicorp/kubernetes<cr>
```

### Configurable settings
| Keys                     | Description                                                      | Options                    |
|--------------------------|------------------------------------------------------------------|----------------------------|
| `url_open_command`       | The shell command to open the url                                | string (default: `open`)   |
| `latest_provider_symbol` | The symbol for indicating that the current version is the latest | string (default: `*`)      |

```lua
require("telescope").setup({
  extensions = {
    terraform_doc = {
      url_open_command = "xdg-open",
      latest_provider_symbol = "  ",
    }
  }
})
```
