# [2.1.0](https://github.com/ANGkeith/telescope-terraform-doc.nvim/compare/v2.0.0...v2.1.0) (2024-06-22)


### Features

* hackery to inject attach_mappings to the search picker ([#34](https://github.com/ANGkeith/telescope-terraform-doc.nvim/issues/34)) ([642b4ef](https://github.com/ANGkeith/telescope-terraform-doc.nvim/commit/642b4ef8ce1e2e2129efdf7139d526a5a0573e77))

# [2.0.0](https://github.com/ANGkeith/telescope-terraform-doc.nvim/compare/v1.3.0...v2.0.0) (2024-06-09)


### Code Refactoring

* use 0.10.0 vim.ui.open for opening url, falling back to custom defined open ([56bd79c](https://github.com/ANGkeith/telescope-terraform-doc.nvim/commit/56bd79c285fbe552ddf7052a9f8d0e19d557f6cc))


### BREAKING CHANGES

* `url_open_command` replaced with `url_open_handler`

# [1.3.0](https://github.com/ANGkeith/telescope-terraform-doc.nvim/compare/v1.2.0...v1.3.0) (2024-01-29)


### Bug Fixes

* error launching telescope via require("telescope").extensions.terraform_doc.terraform_doc() ([#27](https://github.com/ANGkeith/telescope-terraform-doc.nvim/issues/27)) ([0ebfcd3](https://github.com/ANGkeith/telescope-terraform-doc.nvim/commit/0ebfcd3dd618fb867f13e491542cb07e3a5809ff))


### Features

* update the default url_open_command to select command to use based on os ([d9f8b12](https://github.com/ANGkeith/telescope-terraform-doc.nvim/commit/d9f8b12f434a2e8e7cf690c0f1c3c212850e578d))

# [1.2.0](https://github.com/ANGkeith/telescope-terraform-doc.nvim/compare/v1.1.0...v1.2.0) (2022-04-20)


### Features

* open documentation in a split ([#12](https://github.com/ANGkeith/telescope-terraform-doc.nvim/issues/12)) ([5ef6b79](https://github.com/ANGkeith/telescope-terraform-doc.nvim/commit/5ef6b7958ab9868a47bed7faf24b1aef825ba9e1))

# [1.1.0](https://github.com/ANGkeith/telescope-terraform-doc.nvim/compare/v1.0.0...v1.1.0) (2022-04-12)


### Features

* add search terraform module support ([#9](https://github.com/ANGkeith/telescope-terraform-doc.nvim/issues/9)) ([5aa25c0](https://github.com/ANGkeith/telescope-terraform-doc.nvim/commit/5aa25c08f6e43e0a976b5cdc4fd696ac612d78c8))

# 1.0.0 (2022-04-12)


### Bug Fixes

* **api:** escape glob character to prevent it from being interpreted by `curl` ([75c29a0](https://github.com/ANGkeith/telescope-terraform-doc.nvim/commit/75c29a0ac8f0af89081381787166f52d963ec0d4))
