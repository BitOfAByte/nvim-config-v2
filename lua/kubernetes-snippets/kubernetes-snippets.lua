-- plugin/kubernetes_snippets.lua
local M = {}

-- Kubernetes manifest templates
M.templates = {
    deployment = [[
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${1:deployment-name}
  labels:
    app: ${2:app-name}
spec:
  replicas: ${3:1}
  selector:
    matchLabels:
      app: ${2:app-name}
  template:
    metadata:
      labels:
        app: ${2:app-name}
    spec:
      containers:
      - name: ${4:container-name}
        image: ${5:image-name}:${6:tag}
        ports:
        - containerPort: ${7:80}
        resources:
          limits:
            cpu: ${8:500m}
            memory: ${9:512Mi}
          requests:
            cpu: ${10:250m}
            memory: ${11:256Mi}]],

    service = [[
apiVersion: v1
kind: Service
metadata:
  name: ${1:service-name}
spec:
  selector:
    app: ${2:app-name}
  ports:
    - protocol: TCP
      port: ${3:80}
      targetPort: ${4:80}
  type: ${5:ClusterIP}]],
    configmap = [[
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${1:configmap-name}
data:
  ${2:key}: ${3:value}]],
    secret = [[
apiVersion: v1
kind: Secret
metadata:
  name: ${1:secret-name}
type: Opaque
data:
  ${2:key}: ${3:base64-encoded-value}]]
}

-- Function to insert snippet
function M.insert_snippet(snippet_name)
    local template = M.templates[snippet_name]
    if template then
        -- Get current buffer and cursor position
        local bufnr = vim.api.nvim_get_current_buf()
        local row = unpack(vim.api.nvim_win_get_cursor(0))
        local lines = vim.split(template, '\n')
        vim.api.nvim_buf_set_lines(bufnr, row - 1, row - 1, false, lines)
        -- Move cursor to first placeholder
        vim.api.nvim_win_set_cursor(0, {row, 0})
    end
end

-- Function to setup autocommands and commands
function M.setup()
    -- Create user commands for each snippet
    for name, _ in pairs(M.templates) do
        vim.api.nvim_create_user_command(name:gsub("^%l", string.upper), function()
            M.insert_snippet(name)
        end, {})
    end
    -- Create autocommands for YAML files
    vim.api.nvim_create_autocmd({"FileType"}, {
        pattern = {"yaml", "yml"},
        callback = function()
            -- Set up buffer-local keymaps
            vim.keymap.set('i', 'deployment<Tab>', function()
                vim.api.nvim_input("<Esc>")
                M.insert_snippet('deployment')
                vim.api.nvim_input("i")
            end, { buffer = true })
            vim.keymap.set('i', 'service<Tab>', function()
                vim.api.nvim_input("<Esc>")
                M.insert_snippet('service')
                vim.api.nvim_input("i")
            end, { buffer = true })
            vim.keymap.set('i', 'configmap<Tab>', function()
                vim.api.nvim_input("<Esc>")
                M.insert_snippet('configmap')
                vim.api.nvim_input("i")
            end, { buffer = true })
            vim.keymap.set('i', 'secret<Tab>', function()
                vim.api.nvim_input("<Esc>")
                M.insert_snippet('secret')
                vim.api.nvim_input("i")
            end, { buffer = true })
        end
    })
end

return M
