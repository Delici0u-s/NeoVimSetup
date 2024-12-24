vim.o.shell = "powershell.exe"
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "


-- Function to format the current file with clang-format.cmd
local function clang_format()
  -- Get the current file path
  local filepath = vim.fn.expand("%:p")

  -- Ensure the file path is valid
  if filepath == "" then
    vim.api.nvim_err_writeln("No file to format!")
    return
  end

  -- Build the clang-format command
  local cmd = { "clang-format.cmd", filepath }

  -- Run the command and replace the buffer contents
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        -- Replace the entire buffer with the formatted output
        vim.api.nvim_buf_set_lines(0, 0, -1, false, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        -- Print errors if any
        vim.api.nvim_err_writeln(table.concat(data, "\n"))
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("Formatting complete!", vim.log.levels.INFO)
      else
        vim.api.nvim_err_writeln("clang-format.cmd failed with exit code " .. code)
      end
    end,
  })
end

-- Autocmd to add :Format command for C and C++ files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.api.nvim_buf_create_user_command(0, "Format", clang_format, { desc = "Format the current file with clang-format.cmd" })
  end,
})







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


-- vim.defer_fn(function()
--   vim.cmd 'wincmd l'
-- end, 700)

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd 'wincmd l'
    end, 1) -- Delay in milliseconds (e.g., 100ms)
  end,
})


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

vim.opt.shell = 'pwsh'
vim.opt.shellcmdflag = '-nologo -noprofile -ExecutionPolicy RemoteSigned -command'
vim.opt.shellxquote = ''
