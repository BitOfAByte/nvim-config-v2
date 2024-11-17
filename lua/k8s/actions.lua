local M = {}
local api = vim.api
local fn = vim.fn
local kubectl = require('k8s.kubectl')

function M.containers()
  local line = api.nvim_get_current_line()
  local pod_name = line:match("^%S+%s+(%S+)")
  if pod_name then
    kubectl.run_command({'describe', 'pod', pod_name})
  end
end

function M.reload()
  -- Refresh the pod list
  require('k8s').refresh()
end

function M.help()
  local help_text = [[
Kubernetes Navigator Commands:
  <CR>    - Show container details
  gr      - Reload resources
  g?      - Show this help
  gk      - Delete pod
  gp      - Port forward
  gl      - Show logs
  <C-n>   - Switch namespace
  <C-f>   - Filter resources
  <C-a>   - Show aliases
  ]]
  
  vim.notify(help_text, vim.log.levels.INFO)
end

function M.delete_pod()
  local line = api.nvim_get_current_line()
  local pod_name = line:match("^%S+%s+(%S+)")
  if pod_name then
    local confirm = fn.input("Delete pod " .. pod_name .. "? [y/N] ")
    if confirm:lower() == 'y' then
      kubectl.run_command({'delete', 'pod', pod_name})
      M.reload()
    end
  end
end

function M.port_forward()
  local line = api.nvim_get_current_line()
  local pod_name = line:match("^%S+%s+(%S+)")
  if pod_name then
    local port = fn.input("Local port: ")
    local target_port = fn.input("Target port: ")
    if port and target_port then
      kubectl.run_command({'port-forward', pod_name, port .. ':' .. target_port})
    end
  end
end

function M.logs()
  local line = api.nvim_get_current_line()
  local pod_name = line:match("^%S+%s+(%S+)")
  if pod_name then
    kubectl.run_command({'logs', pod_name})
  end
end

function M.namespace()
  local namespaces = kubectl.get_namespaces()
  -- TODO: Implement namespace selection UI
  vim.notify("Available namespaces: " .. table.concat(namespaces, ", "))
end

function M.filter()
  local filter = fn.input("Filter: ")
  -- TODO: Implement resource filtering
end

function M.aliases()
  -- TODO: Implement kubectl aliases management
  vim.notify("Aliases management not implemented yet")
end

return M

