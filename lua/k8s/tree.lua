local M = {}
local api = vim.api

-- Tree node structure
local Node = {}
function Node:new(name, type, parent)
  local node = {
    name = name,
    type = type,
    parent = parent,
    children = {},
    expanded = false
  }
  setmetatable(node, { __index = Node })
  return node
end

-- Tree view buffer
function M.create_tree_buffer()
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'modifiable', false)
  
  -- Set keymaps
  local opts = { noremap = true, silent = true }
  api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':lua require("k8s.tree").expand_node()<CR>', opts)
  api.nvim_buf_set_keymap(buf, 'n', '<BS>', ':lua require("k8s.tree").collapse_node()<CR>', opts)
  
  return buf
end

-- Expand node under cursor
function M.expand_node()
  local line = api.nvim_win_get_cursor(0)[1]
  -- Implementation for expanding nodes
end

-- Collapse node under cursor
function M.collapse_node()
  local line = api.nvim_win_get_cursor(0)[1]
  -- Implementation for collapsing nodes
end

return M
