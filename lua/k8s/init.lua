local M = {}
local api = vim.api
local fn = vim.fn

M.config = {
  kubectl_path = '/usr/bin/kubectl',
  default_namespace = 'default',
  log_split_direction = 'vertical',
  highlight_groups = {
    KubeResourceName = { fg = '#9b87f5', bold = true },
    KubeNamespace = { fg = '#7E69AB', italic = true },
    KubeStatus = { fg = '#33C3F0' },
    KubeError = { fg = '#ea384c', bold = true },
  }
}

-- State
local state = {
  buf = nil,
  win = nil
}

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
  require('k8s.commands').setup()
  require('k8s.highlights').setup()
  
  -- Create TUI buffer
  state.buf = require('k8s.tui').create_buffer()
  require('k8s.tui').setup_keymaps(state.buf)
  
  -- Initial refresh
  M.refresh()
end

-- Refresh the TUI
function M.refresh()
  local kubectl = require('k8s.kubectl')
  local context = fn.system(M.config.kubectl_path .. ' config current-context'):gsub('\n', '')
  local pods = kubectl.get_resource_tree()
  
  local data = {
    context = context,
    namespace = M.config.default_namespace,
    pods = pods
  }
  
  require('k8s.tui').render(state.buf, data)
end

return M
