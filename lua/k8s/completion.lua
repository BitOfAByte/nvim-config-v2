local M = {}
local fn = vim.fn

function M.complete_kubectl(line)
  local words = vim.split(line, '%s+')
  local cmd = table.concat(words, ' ')
  -- Get completion suggestions from kubectl
  local output = fn.system(string.format('kubectl __complete %s', cmd))
  local suggestions = vim.split(output, '\n')
  return suggestions
end

return M
