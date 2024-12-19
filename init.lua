vim.o.shell = "powershell.exe"
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  -- Default op
  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

vim.opt.shadafile = 'NONE'
vim.cmd('NvimTreeToggle')
vim.cmd 'vertical resize -8'
vim.defer_fn(function()
  vim.cmd 'wincmd l'
end, 4)

vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
        -- Check the current number of open windows
        if #vim.api.nvim_list_wins() == 1 then
            local bufname = vim.api.nvim_buf_get_name(0)
            -- Check if the current buffer name is "NvimTree_1"
            if bufname:match("NvimTree_1") then
                vim.cmd("quit") -- Close NvimTree if it's the only window
            end
        end
    end,
    desc = "Close NvimTree if it's the only window open",
})

vim.cmd("set shiftwidth=4")
vim.cmd("set tabstop=4")
