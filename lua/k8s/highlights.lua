local M = {}
local api = vim.api
local config = require('k8s').config

function M.setup()
  -- Define highlight groups
  for group, colors in pairs(config.highlight_groups) do
    api.nvim_set_hl(0, group, colors)
  end
end

function M.apply_highlights(buf)
  -- Apply syntax highlighting rules
  vim.cmd([[
    syntax match KubeResourceName /^\S\+/
    syntax match KubeNamespace /\v\w+(-\w+)*/
    syntax match KubeStatus /\v(Running|Pending|Succeeded|Failed|Unknown)/
    syntax match KubeError /\vError|CrashLoopBackOff|ImagePullBackOff/
  ]])
end

return M
