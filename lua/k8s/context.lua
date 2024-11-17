local M = {}
local fn = vim.fn
local config = require('k8s').config

function M.get_contexts()
  local cmd = string.format('%s config get-contexts -o name', config.kubectl_path)
  local output = fn.system(cmd)
  return vim.split(output, '\n')
end

function M.switch_context(context)
  local cmd = string.format('%s config use-context %s', config.kubectl_path, context)
  local output = fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(output, vim.logs.levels.ERROR)
    return
  end
  vim.notify('Switched to context: ' .. context)
end

return M
