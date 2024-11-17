local M = {}
local api = vim.api

-- Create the main TUI buffer
function M.create_buffer()
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'modifiable', false)
  api.nvim_buf_set_option(buf, 'filetype', 'k8s')
  return buf
end

-- Format pod data into display lines
function M.format_pod_data(pods)
  local lines = {
    "NAMESPACE | NAME | READY | STATUS | RESTARTS | IP | NODE | AGE",
    string.rep("-", 120)
  }
  for _, pod in ipairs(pods) do
    local line = string.format(
      "%-20s %-30s %s/%-d %-10s %-3d %-15s %-15s %s",
      pod.namespace,
      pod.name,
      pod.ready_containers,
      pod.total_containers,
      pod.status,
      pod.restarts,
      pod.ip or "N/A",
      pod.node,
      pod.age
    )
    table.insert(lines, line)
  end
  return lines
end

-- Render the TUI
function M.render(buf, data)
  api.nvim_buf_set_option(buf, 'modifiable', true)
  -- Add header
  local header = {
    "Context: " .. data.context,
    "Namespace: " .. data.namespace,
    "",
    "Hint: <CR> containers | gr reload | g? help | gk delete pod | gp PF | gl logs | <C-N> namespace | <C-F> filter | <C-A> aliases",
    ""
  }
  -- Format pod data
  local pod_lines = M.format_pod_data(data.pods)
  -- Combine all lines
  local lines = vim.list_extend(header, pod_lines)
  -- Update buffer content
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_set_option(buf, 'modifiable', false)
end

-- Set up keymaps for the TUI buffer
function M.setup_keymaps(buf)
  local opts = { noremap = true, silent = true }
  local mappings = {
    ['<CR>'] = 'containers',
    ['gr'] = 'reload',
    ['g?'] = 'help',
    ['gk'] = 'delete_pod',
    ['gp'] = 'port_forward',
    ['gl'] = 'logs',
    ['<C-n>'] = 'namespace',
    ['<C-f>'] = 'filter',
    ['<C-a>'] = 'aliases'
  }
  for key, action in pairs(mappings) do
    api.nvim_buf_set_keymap(buf, 'n', key,
      string.format(":lua require('k8s.actions').%s()<CR>", action),
      opts)
  end
end

return M

