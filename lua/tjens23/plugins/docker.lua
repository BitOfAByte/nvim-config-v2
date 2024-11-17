return {
  dir = vim.fn.stdpath("config") .. "/lua/docker",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("docker").setup()
  end,
}

