return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },

  vim.keymap.set("n", "<leader>gcoc", "<cmd>CopilotChatOpen<CR>", { desc = "Opens github copilot chat"});
  vim.keymap.set("n", "<leader>gccc", "<cmd>CopilotChatClose<CR>",  { desc = "Closes github copilot chat" });
  vim.keymap.set("n", "<leader>gcsc", function()
        vim.ui.input({
          prompt = "Enter name of chat",
        }, function(input)
          if input and input ~= "" then
            vim.cmd("CopilotChatSave " .. input)
          end
        end)
      end,
    {desc = "Save chat with name"
    });

  vim.keymap.set("n", "<leader>gclc", function()
    vim.ui.input({
      prompt = "Enter name of chat",
    }, function(input)
        if input and input ~= "" then
          vim.cmd("CopilotChatLoad " .. input)
        end
      end)
  end,
    { desc = "Loads saved chat given a name"})
}
