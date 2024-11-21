return {
  dir = vim.fn.stdpath("config") .. "/lua/k8s",
  config = function()
    require("k8s").setup()

    vim.keymap.set("n", "<leader>ck", function()
      require("k8s.tui").create_buffer()
      require("k8s").refresh()
    end, { desc = "Kubernetes TUI" })
  end
}
