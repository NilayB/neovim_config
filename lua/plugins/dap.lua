return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")

    if not dap.adapters.codelldb then
      dap.adapters.codelldb = {
        type = "server",
        host = "127.0.0.1",
        port = "${port}",
        executable = {
          command = "codelldb",
          args = { "--port", "${port}" },
        },
      }
    end

    if not dap.configurations.cpp then
      dap.configurations.cpp = {
        {
          name = "Launch C/C++ Executable",
          type = "codelldb",
          request = "launch",

          -- Dynamically prompt for the executable with tab-completion
          program = function()
            local cwd = vim.fn.getcwd()
            local default_path = cwd .. "/"

            -- Smart default: check if a "build" or "out" directory exists
            if vim.fn.isdirectory(cwd .. "/build") == 1 then
              default_path = cwd .. "/build/"
            elseif vim.fn.isdirectory(cwd .. "/out") == 1 then
              default_path = cwd .. "/out/"
            end

            -- The "file" argument enables standard terminal tab-completion
            local exe = vim.fn.input("Path to executable: ", default_path, "file")
            return vim.trim(exe)
          end,

          -- Dynamically prompt for CLI arguments
          args = function()
            local args_string = vim.fn.input("Arguments (space separated, leave blank for none): ")
            if vim.trim(args_string) == "" then
              return nil
            end
            return vim.split(args_string, " +")
          end,

          cwd = "${workspaceFolder}",
          stopOnEntry = false,

          -- Routes std::cin / std::cout inside an integrated terminal
          runInTerminal = true,

          -- Standard environment setup for smooth terminal output
          env = function()
            local variables = {}
            for k, v in pairs(vim.fn.environ()) do
              variables[k] = v
            end
            return variables
          end,

          -- Ensures data structures like std::vector and std::string print out elegantly
          sourceLanguages = { "cpp", "c" },
        },
      }
    end

    -- Alias C to C++
    dap.configurations.c = dap.configurations.cpp
  end,
}
