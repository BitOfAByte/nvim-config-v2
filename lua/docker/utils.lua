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

-- Function to confirm dangerous actions
local function confirm_action(prompt, callback)
  vim.ui.select({ 'Yes', 'No' }, {
    prompt = prompt .. " (Yes/No)",
  }, function(choice)
    if choice == 'Yes' then
      callback()
    end
  end)
end

-- Function to perform container action
local function perform_container_action(action, container_id, container_status)
  -- Close the picker first
  if action == "delete" and container_status == "running" then
    vim.notify("Cannot delete running container. Stop it first.", vim.log.levels.WARN)
    return
  end
  
  if action == "start" and container_status == "running" then
    vim.notify("Container is already running.", vim.log.levels.INFO)
    return
  end
  
  if action == "stop" and container_status ~= "running" then
    vim.notify("Container is not running.", vim.log.levels.INFO)
    return
  end

  -- Confirm dangerous actions
  if action == "delete" then
    confirm_action("Are you sure you want to delete this container?", function()
      execute_docker_command("rm", container_id)
    end)
  else
    local commands = {
      start = "start",
      stop = "stop",
      restart = "restart",
      delete = "rm",
      logs = "logs -f"
    }
    
    if action == "logs" then
      show_container_logs(container_id)
    else
      execute_docker_command(commands[action], container_id)
    end
  end
end

-- Main function to show docker containers
function M.show_docker_containers(opts)
  opts = opts or {}

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
          "",
          "Keybindings:",
          "s - Start container",
          "x - Stop container",
          "r - Restart container",
          "d - Delete container",
          "l - View logs",
          "<CR> - Action menu"
        }
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, details)
      end
    }),
    attach_mappings = function(prompt_bufnr, map)
      -- Helper function to get selection and close
      local function get_selection_and_close()
        local selection = actions_state.get_selected_entry()
        actions.close(prompt_bufnr)
        return selection
      end

      -- Add keybindings for container actions
      map('i', 's', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("start", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('i', 'x', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("stop", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('i', 'r', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("restart", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('i', 'd', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("delete", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('i', 'l', function()
        local selection = get_selection_and_close()
        perform_container_action("logs", selection.values.ID)
      end)

      -- Add normal mode mappings as well
      map('n', 's', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("start", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('n', 'x', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("stop", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('n', 'r', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("restart", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('n', 'd', function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        perform_container_action("delete", selection.values.ID, status:match("^up") and "running" or "stopped")
      end)

      map('n', 'l', function()
        local selection = get_selection_and_close()
        perform_container_action("logs", selection.values.ID)
      end)

      -- Default action (show menu)
      actions.select_default:replace(function()
        local selection = get_selection_and_close()
        local status = selection.values.Status:lower()
        local is_running = status:match("^up")
        
        -- Show selection menu
        vim.ui.select({
          "Start container",
          "Stop container",
          "Restart container",
          "Delete container",
          "View logs"
        }, {
          prompt = "Select action for container " .. selection.values.ID:sub(1, 12)
        }, function(choice)
          if choice then
            local action_map = {
              ["Start container"] = "start",
              ["Stop container"] = "stop",
              ["Restart container"] = "restart",
              ["Delete container"] = "delete",
              ["View logs"] = "logs"
            }
            perform_container_action(action_map[choice], selection.values.ID, is_running and "running" or "stopped")
          end
        end)
      end)

      return true
    end
  }):find()
end

return M
