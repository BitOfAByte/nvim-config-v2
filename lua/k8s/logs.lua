local M = {}
local api = vim.api
local config = require('k8s-nvim').config
local fn = vim.fn;

function M.tail_logs(pod, container)
  local cmd = string.format('%s logs -f %s', config.kubectl_path, pod)
  if container then
    cmd = cmd .. ' -c ' .. container
  end
  
  -- Create floating window for logs
  local buf = api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  
  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded'
  }
  
  local win = api.nvim_open_win(buf, true, opts)
  
  -- Start job to stream logs
  local job_id = fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if data then
        api.nvim_buf_set_lines(buf, -1, -1, false, data)
      end
    end
  })
  
  -- Clean up on window close
  api.nvim_create_autocmd('WinClosed', {
    pattern = tostring(win),
    callback = function()
      fn.jobstop(job_id)
    end
  })
end

return M
