-- Install plugins
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('https://github.com/zootedb0t/citruszest.nvim')
Plug('https://github.com/nvim-lua/plenary.nvim') -- Necessary for telescope
Plug('https://github.com/nvim-telescope/telescope.nvim') -- Find things
Plug('https://github.com/nvim-telescope/telescope-file-browser.nvim')
Plug('https://github.com/neovim/nvim-lspconfig') -- LSP
Plug('https://github.com/lspcontainers/lspcontainers.nvim') -- LSP containers
Plug('https://github.com/nvim-treesitter/nvim-treesitter', { ['branch'] = 'master' }) -- Treesitter
Plug('https://github.com/folke/trouble.nvim')
Plug('https://github.com/ThePrimeagen/harpoon') -- Buffer switching
vim.call('plug#end')

-- Leader key
vim.g.mapleader = " "

-- Theme
require("citruszest").setup({})
vim.cmd([[colorscheme citruszest]])

-- General options
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.wo.relativenumber = true

-- Disable providers I don't use so they don't complain
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- Telescope
local builtin = require("telescope.builtin")
require("telescope").setup {
  extensions = {
    file_browser = {
      theme = "ivy",
      hijack_netrw = true,
    },
  },
}
require("telescope").load_extension("file_browser")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { desc = "File browser" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Buffers" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bx", ":bdelete<CR>", { desc = "Close buffer" })

-- Diagnostics
require("trouble").setup({})
vim.keymap.set("n", "<leader>bd", function()
  require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } })
end, { desc = "Buffer diagnostics (Trouble)" })

vim.keymap.set("n", "<leader>be", function()
  if vim.diagnostic.config().virtual_text then
    vim.diagnostic.config({ virtual_text = false })
  else
    vim.diagnostic.config({ virtual_text = { prefix = " " } })
  end
end, { desc = "Toggle inline diagnostics" })

vim.keymap.set("n", "<leader>df", function()
  vim.diagnostic.open_float({ border = "rounded", focusable = false })
end, { desc = "Show diagnostics for current line" })

vim.keymap.set("n", "<leader>th", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints (variable types)" })

-- Harpoon (buffer switching)
require("harpoon").setup({})
local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", harpoon_mark.add_file, { desc = "Harpoon: add file to list" })
vim.keymap.set("n", "<C-e>", harpoon_ui.toggle_quick_menu, { desc = "Harpoon: toggle quick menu" })
vim.keymap.set("n", "<C-h>", function() harpoon_ui.nav_file(1) end, { desc = "Harpoon: go to file 1" })
vim.keymap.set("n", "<C-j>", function() harpoon_ui.nav_file(2) end, { desc = "Harpoon: go to file 2" })
vim.keymap.set("n", "<C-k>", function() harpoon_ui.nav_file(3) end, { desc = "Harpoon: go to file 3" })
vim.keymap.set("n", "<C-l>", function() harpoon_ui.nav_file(4) end, { desc = "Harpoon: go to file 4" })
vim.keymap.set("n", "<leader>hn", harpoon_ui.nav_next, { desc = "Harpoon: next mark" })
vim.keymap.set("n", "<leader>hp", harpoon_ui.nav_prev, { desc = "Harpoon: previous mark" })

-- Search & replace (built-in)
vim.keymap.set("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "Replace word under cursor in this file" })

local function visual_selection()
  local start = vim.fn.getpos("'<")
  local finish = vim.fn.getpos("'>")
  local lines = vim.api.nvim_buf_get_lines(0, start[2] - 1, finish[2], false)
  if #lines == 0 then return "" end
  lines[1] = string.sub(lines[1], start[3])
  lines[#lines] = string.sub(lines[#lines], 1, finish[3])
  return table.concat(lines, "\n")
end

vim.keymap.set("x", "<leader>sr", function()
  local sel = visual_selection()
  if sel == "" then return end
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(":%s/\\V" .. vim.fn.escape(sel, "\\") .. "//g<Left><Left>", true, false, true),
    "n", false)
end, { desc = "Replace visual selection in this file" })

vim.keymap.set("n", "<leader>sR", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then return end
  vim.cmd.grep(word)
  vim.cmd("copen")
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(":cdo s/\\<" .. word .. "\\>//gc<Left><Left><Left>", true, false, true),
    "n", false)
end, { desc = "Replace word under cursor across project" })

-- LSP servers
vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = {
      inlayHints = {
        type = true,
        parameterHints = { enable = true },
        closureReturnTypeHints = { enable = 'always' },
      },
    },
  },
})
vim.lsp.enable('rust_analyzer')

vim.lsp.config('pylsp', {})
vim.lsp.enable('pylsp')

vim.lsp.config('gopls', {})
vim.lsp.enable('gopls')
