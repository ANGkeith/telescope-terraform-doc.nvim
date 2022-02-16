execute 'silent !curl -fLo ./plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
autocmd VimEnter * PlugInstall --sync | :q | source ./init.vim

call plug#begin('./plugged')
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'ANGkeith/telescope-terraform-doc.nvim'

Plug 'tanvirtin/monokai.nvim'
call plug#end()

colorscheme monokai_pro

lua <<EOF
require("telescope").setup({
  extensions = {
    terraform_doc = {
      latest_provider_symbol = "  ",
    }
  }
})
require("telescope").load_extension("terraform_doc")
EOF
