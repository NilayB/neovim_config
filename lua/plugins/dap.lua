-- ~/.config/nvim/lua/plugins/dap.lua
--
-- C/C++ debugging for any build system (CMake + presets, Make, Meson, bare clang -g).
-- Uses `opts` (not `config`) so LazyVim's own nvim-dap setup (signs, .vscode/launch.json
-- loading, keymaps) stays intact. Assumes the LazyVim `dap.core` extra is enabled.
return {
  "mfussenegger/nvim-dap",
  opts = function()
    local dap = require("dap")
    local uv = vim.uv or vim.loop
    local is_win = vim.fn.has("win32") == 1

    ---------------------------------------------------------------------------
    -- Adapter: codelldb preferred, lldb-dap as fallback
    ---------------------------------------------------------------------------
    local codelldb = vim.fn.exepath("codelldb")
    if codelldb == "" then
      codelldb = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
    end

    local adapter -- name used as `type` in the configurations below
    if vim.fn.executable(codelldb) == 1 then
      adapter = "codelldb"
      -- Assigned unconditionally (no `if not dap.adapters.x`) so no other spec can
      -- leave behind a definition without `executable`, which is what produces the
      -- literal "${port}" ECONNREFUSED error.
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb,
          args = { "--port", "${port}" },
          detached = not is_win, -- codelldb needs detached = false on Windows
        },
      }
    else
      local lldb_dap = vim.fn.exepath("lldb-dap")
      if lldb_dap == "" then
        lldb_dap = vim.fn.exepath("lldb-vscode") -- older LLVM name
      end
      if lldb_dap ~= "" then
        adapter = "lldb"
        dap.adapters.lldb = { type = "executable", command = lldb_dap, name = "lldb" }
      end
    end

    if not adapter then
      vim.notify(
        "No C/C++ debug adapter found. Install `codelldb` via :Mason (or `lldb-dap`).",
        vim.log.levels.WARN
      )
      return
    end

    ---------------------------------------------------------------------------
    -- Helpers
    ---------------------------------------------------------------------------
    local function project_root()
      local ok, root = pcall(function()
        return LazyVim.root()
      end)
      if ok and root and root ~= "" then
        return root
      end
      local markers = { ".git", "CMakeLists.txt", "Makefile", "meson.build", "Cargo.toml" }
      return (vim.fs.root and vim.fs.root(0, markers)) or vim.fn.getcwd()
    end

    -- Directories never worth descending into when looking for binaries
    local skip_dirs = {
      [".git"] = true,
      [".cache"] = true,
      [".venv"] = true,
      ["node_modules"] = true,
      ["CMakeFiles"] = true,
      ["_deps"] = true,
    }
    -- Build artifacts that are executable-looking but not launchable
    local non_exe_ext = {
      a = true, o = true, obj = true, lib = true, dll = true,
      dylib = true, pdb = true, ilk = true, exp = true,
    }

    -- Real native executable: not a script, not a library, checked by file magic
    local function is_native_executable(path)
      if path:match("%.so[%.%d]*$") then
        return false
      end
      local ext = path:match("%.(%w+)$")
      if ext and non_exe_ext[ext:lower()] then
        return false
      end
      if vim.fn.executable(path) ~= 1 then
        return false
      end
      local f = io.open(path, "rb")
      if not f then
        return false
      end
      local head = f:read(4)
      f:close()
      return head ~= nil and (head == "\127ELF" or head:sub(1, 2) == "MZ")
    end

    local function find_executables(root)
      local found = {}
      local iter = vim.fs.dir(root, {
        depth = 6,
        -- returning false stops descent into that directory
        skip = function(p)
          return not skip_dirs[vim.fs.basename(p)]
        end,
      })
      for rel, kind in iter do
        if kind == "file" or kind == "link" then
          local full = root .. "/" .. rel
          if is_native_executable(full) then
            local st = uv.fs_stat(full)
            table.insert(found, { path = full, rel = rel, mtime = st and st.mtime.sec or 0 })
          end
        end
      end
      -- newest build first: usually the binary you just compiled
      table.sort(found, function(a, b)
        return a.mtime > b.mtime
      end)
      return found
    end

    local function age(mtime)
      local d = os.time() - mtime
      if d < 60 then
        return d .. "s ago"
      elseif d < 3600 then
        return math.floor(d / 60) .. "m ago"
      elseif d < 86400 then
        return math.floor(d / 3600) .. "h ago"
      end
      return math.floor(d / 86400) .. "d ago"
    end

    local MANUAL = { manual = true }

    -- Returns a coroutine so nvim-dap waits for the (async) picker result
    local function pick_program()
      return coroutine.create(function(dap_co)
        local root = project_root()
        local items = find_executables(root)
        table.insert(items, MANUAL)

        local function finish(value)
          -- schedule so this also works if the picker calls back synchronously
          vim.schedule(function()
            coroutine.resume(dap_co, value)
          end)
        end

        vim.ui.select(items, {
          prompt = "Executable to debug:",
          format_item = function(item)
            if item == MANUAL then
              return "Type a path..."
            end
            return string.format("%s  (%s)", item.rel, age(item.mtime))
          end,
        }, function(choice)
          if not choice then
            return finish(dap.ABORT)
          end
          if choice ~= MANUAL then
            return finish(choice.path)
          end
          local input = vim.trim(vim.fn.input("Path to executable: ", root .. "/", "file"))
          if input == "" or vim.fn.executable(input) ~= 1 then
            if input ~= "" then
              vim.notify("Not an executable: " .. input, vim.log.levels.ERROR)
            end
            return finish(dap.ABORT)
          end
          finish(input)
        end)
      end)
    end

    -- Shell-style splitting: handles "quoted args" and 'single quotes'
    local function split_args(s)
      local args, cur, quote, has = {}, {}, nil, false
      local i = 1
      while i <= #s do
        local c = s:sub(i, i)
        if quote then
          if c == quote then
            quote = nil
          elseif c == "\\" and quote == '"' and not is_win and i < #s then
            i = i + 1
            table.insert(cur, s:sub(i, i))
          else
            table.insert(cur, c)
          end
        elseif c == '"' or c == "'" then
          quote, has = c, true
        elseif c:match("%s") then
          if has or #cur > 0 then
            table.insert(args, table.concat(cur))
            cur, has = {}, false
          end
        elseif c == "\\" and not is_win and i < #s then
          i = i + 1
          table.insert(cur, s:sub(i, i))
        else
          table.insert(cur, c)
        end
        i = i + 1
      end
      if has or #cur > 0 then
        table.insert(args, table.concat(cur))
      end
      return args
    end

    local last_args = ""
    local function prompt_args()
      last_args = vim.fn.input("Program arguments: ", last_args)
      return split_args(last_args)
    end

    ---------------------------------------------------------------------------
    -- Configurations
    ---------------------------------------------------------------------------
    local function launch(name, with_args)
      local cfg = {
        name = name,
        type = adapter,
        request = "launch",
        program = pick_program,
        cwd = project_root,
        stopOnEntry = false,
      }
      if with_args then
        cfg.args = prompt_args
      end
      if adapter == "codelldb" then
        cfg.terminal = "integrated" -- stdin/stdout in a terminal instead of the debug console
        cfg.sourceLanguages = { "cpp", "c" }
      end
      return cfg
    end

    local configurations = {
      launch("Launch", false),
      launch("Launch with args", true),
      {
        name = "Attach to process",
        type = adapter,
        request = "attach",
        pid = require("dap.utils").pick_process,
        cwd = project_root,
      },
    }

    dap.configurations.cpp = configurations
    dap.configurations.c = configurations
  end,
}
