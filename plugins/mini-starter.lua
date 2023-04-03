-- start screen
return {
  -- disable alpha
  { "goolord/alpha-nvim", enabled = false },

  -- enable mini.starter
  {
    "echasnovski/mini.starter",
    version = "0.8.0",
    event = "VimEnter",
    opts = function()
      local logo = table.concat({
        "          ██╗  ██╗██████╗    ███████╗██████╗          Z",
        "          ██║  ██║╚════██╗   ╚════██║╚════██╗      Z",
        "          ███████║ █████╔╝█████╗ ██╔╝ █████╔╝   z",
        "          ╚════██║██╔═══╝ ╚════╝██╔╝  ╚═══██╗ z",
        "               ██║███████╗      ██║  ██████╔╝",
        "               ╚═╝╚══════╝      ╚═╝  ╚═════╝ ",
      }, "\n")

      local pad = string.rep(" ", 22)
      -- A content hook to add icons as separate content unit to not disrupt query
      --stylua: ignore start
      local new_icon_unit = function(icon)
        return { type = 'icon', string = pad .. icon .. '  ', hl = 'String' }
      end 

      local icon_units = {
        ['Find file']    = new_icon_unit(''),
        ['Recent files'] = new_icon_unit(''),
        ['Grep text']    = new_icon_unit(''),
        ['Config']       = new_icon_unit(''),
        ['Lazy']         = new_icon_unit(''),
        ['New file']     = new_icon_unit(''),
        ['Quit']         = new_icon_unit(''),
      }

      local hook_add_icons = function(content)
        for _, line in ipairs(content) do
          -- If hook is applied first, then item is first content unit in line
          local item = line[1].item
          if item ~= nil then table.insert(line, 1, icon_units[item.name]) end
        end
        return content
      end

      local starter = require('mini.starter')
      local new_section =
      function(name, action, section) return { name = name, action = action, section = pad .. section } end

      local config = {
        evaluate_single = true,
        header = logo,
        items = {
          new_section("Find file",    "Telescope find_files find_command=rg,--hidden,--files", "Telescope"),
          new_section("Recent files", "Telescope oldfiles",   "Telescope"),
          new_section("Grep text",    "Telescope live_grep",  "Telescope"),
          new_section("Config",       "e $MYVIMRC",           "Config"),
          new_section("Lazy",         "Lazy",                 "Config"),
          new_section("New file",     "ene | startinsert",    "Built-in"),
          new_section("Quit",         "qa",                   "Built-in"),
        },
        content_hooks = {
          hook_add_icons,
          starter.gen_hook.aligning("center", "center"),
        },
      }
      --stylua: ignore end

      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function() require("lazy").show() end,
        })
      end

      local starter = require "mini.starter"
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local pad_footer = string.rep(" ", 8)
          starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(starter.refresh)
        end,
      })
    end,
  },
}
