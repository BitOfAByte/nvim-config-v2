local utils = require("docker.utils")
local M = {}
function M.setup()
  -- Set up the keymap
  vim.keymap.set('n', '<Leader>di', function()
    utils.show_docker_images()
  end, { desc = 'Docker Images' })
end

return M
