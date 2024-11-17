local M = {}
local api = vim.api

function M.setup()
  -- Register commands
  api.nvim_create_user_command('Kubectl', function(opts)
    require('k8s.kubectl').run_command(opts.args)
  end, {
    nargs = '+',
    complete = function(_, line)
      return require('k8s.completion').complete_kubectl(line)
    end
  })

  api.nvim_create_user_command('Kubectx', function(opts)
    require('k8s.context').switch_context(opts.args)
  end, {
    nargs = 1,
    complete = function()
      return require('k8s.context').get_contexts()
    end
  })
end

return M

