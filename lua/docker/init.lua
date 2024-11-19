local utils = require("docker.utils")
local M = {}
function M.setup()
  -- Set up the keymap
  vim.keymap.set('n', '<Leader>di', function()
    utils.show_docker_images()
  end, { desc = 'Docker Images' })
  vim.keymap.set('n', '<Leader>dc', function()
    utils.show_docker_containers()
  end, { desc = 'Docker Containers' })
end

return M
