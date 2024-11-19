-- File: lua/docker_utils.lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local previewers = require("telescope.previewers")
local utils = require("telescope.utils")
local log = require("plenary.log")
local actions = require("telescope.actions")
local actions_state = require('telescope.actions.state')

log.level = "debug"

local M = {}

-- Main function to show docker images
function M.show_docker_images(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Docker Images",
    finder = finders.new_async_job({
      command_generator = function()
        return {"docker", "images", "--format", "json"}
      end,
      entry_maker = function(entry)
        local parsed = vim.json.decode(entry)
        if parsed then
          return {
            values = parsed,
            display = parsed.Repository,
            ordinal = parsed.Repository .. ':' .. parsed.Tag,
          }
        end
      end
    }),
    sorter = config.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer({
      title = "Docker Image Details",
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true,
        vim.tbl_flatten({"#" .. entry.values.ID, vim.split(vim.inspect(entry.values),'\n')}))
      end
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = actions_state.get_selected_entry()
        actions.close(prompt_bufnr)
        -- Open a new split with a terminal running the docker container
        vim.cmd('split')
        vim.cmd('terminal docker run -it ' .. selection.values.Repository)
      end)
      return true
    end
  }):find()
end

-- Function to execute a docker command and show the output
local function execute_docker_command(command, container_id)
  vim.cmd('split')
  vim.cmd('terminal docker ' .. command .. ' ' .. container_id)
end

-- Function to show container logs
local function show_container_logs(container_id)
  vim.cmd('split')
  vim.cmd('terminal docker logs -f ' .. container_id)
end

-- Main function to show docker containers
function M.show_docker_containers(opts)
  opts = opts or {}
  
  -- Container action menu
  local function container_action_menu(container_id, container_status)
    local actions_menu = {
      { name = "Start container", cmd = "start", enabled = container_status ~= "running" },
      { name = "Stop container", cmd = "stop", enabled = container_status == "running" },
      { name = "Restart container", cmd = "restart", enabled = true },
      { name = "Delete container", cmd = "rm", enabled = container_status ~= "running" },
      { name = "View logs", cmd = "logs", enabled = true },
    }

    -- Filter out disabled actions
    local available_actions = vim.tbl_filter(function(action)
      return action.enabled
    end, actions_menu)

    -- Create selection list
    local action_names = vim.tbl_map(function(action)
      return action.name
    end, available_actions)

    -- Show selection menu
    vim.ui.select(action_names, {
      prompt = "Select action for container " .. container_id:sub(1, 12),
    }, function(choice)
      if choice then
        -- Find the selected action
        for _, action in ipairs(available_actions) do
          if action.name == choice then
            if action.cmd == "logs" then
              show_container_logs(container_id)
            else
              execute_docker_command(action.cmd, container_id)
            end
            break
          end
        end
      end
    end)
  end

  pickers.new(opts, {
    prompt_title = "Docker Containers",
    finder = finders.new_async_job({
      command_generator = function()
        return {"docker", "ps", "-a", "--format", "json"}
      end,
      entry_maker = function(entry)
        local parsed = vim.json.decode(entry)
        if parsed then
          -- Create a display string with status and name
          local display = string.format(
            "%-20s %-15s %-30s",
            parsed.ID:sub(1, 12),
            parsed.Status:gsub("^Up ", "↑"):gsub("^Exited ", "↓"),
            parsed.Names
          )
          
          return {
            values = parsed,
            display = display,
            ordinal = parsed.Names .. parsed.Status,
          }
        end
      end
    }),
    sorter = config.generic_sorter(opts),
    previewer = previewers.new_buffer_previewer({
      title = "Container Details",
      define_preview = function(self, entry)
        local details = {
          "Container ID: " .. entry.values.ID,
          "Name: " .. entry.values.Names,
          "Image: " .. entry.values.Image,
          "Command: " .. entry.values.Command,
          "Created: " .. entry.values.CreatedAt,
          "Status: " .. entry.values.Status,
          "Ports: " .. (entry.values.Ports or "None"),
        }
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, details)
      end
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local selection = actions_state.get_selected_entry()
        actions.close(prompt_bufnr)
        -- Get container status (running or not)
        local status = selection.values.Status:lower()
        local is_running = status:match("^up")
        container_action_menu(selection.values.ID, is_running and "running" or "stopped")
      end)
      return true
    end
  }):find()
end

return M
