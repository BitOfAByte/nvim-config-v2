local M = {}
local api = vim.api
local fn = vim.fn
local config = require('k8s.init').config

function M.run_command(args)
  local cmd = string.format('%s %s', config.kubectl_path, table.concat(args, ' '))
  local output = fn.system(cmd)
  
  if vim.v.shell_error ~= 0 then
    vim.notify(output, vim.log.levels.ERROR)
    return
  end

  -- Create buffer for output
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, '\n'))
  
  -- Apply syntax highlighting
  require('k8s.highlights').apply_highlights(buf)
  
  -- Open in a new window
  vim.cmd('vsplit')
  local win = api.nvim_get_current_win()
  api.nvim_win_set_buf(win, buf)
end

function M.get_namespaces()
  local cmd = string.format('%s get namespaces -o name', config.kubectl_path)
  local output = fn.system(cmd)
  return vim.split(output, '\n')
end

-- Function to get resource hierarchy with detailed information
function M.get_resource_tree()
  local cmd = string.format('%s get pods --all-namespaces -o wide', config.kubectl_path)
  local output = fn.system(cmd)
  local pods = {}
  
  for line in output:gmatch("[^\r\n]+") do
    local namespace, name, ready, status, restarts, age, ip, node = 
      line:match("(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")
    
    if namespace and name and name ~= "NAME" then
      local ready_count, total_count = ready:match("(%d+)/(%d+)")
      table.insert(pods, {
        namespace = namespace,
        name = name,
        ready_containers = tonumber(ready_count),
        total_containers = tonumber(total_count),
        status = status,
        restarts = tonumber(restarts),
        age = age,
        ip = ip,
        node = node
      })
    end
  end
  
  return pods
end

return M
