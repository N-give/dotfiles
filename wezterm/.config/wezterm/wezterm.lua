local wezterm = require('wezterm')
local config = {}

if wezterm.builder then
  config = wezterm.config_builder()
end

config.enable_wayland = false

config.color_scheme = 'Catppuccin Mocha'

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.font = wezterm.font_with_fallback {
  'Monoid',
  'Fira Code',
}
config.font_size = 16.0
config.front_end = 'WebGpu'
config.audible_bell = "Disabled"

config.default_prog = { 'nu' }
-- config.default_prog = { '/run/current-system/sw/bin/bash' }

config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 1000,
}

local current_pane_domain = {
  domain = 'CurrentPaneDomain'
}

local act = wezterm.action
config.keys = {
  {
    -- Select split direction
    key = 'S',
    mods = 'LEADER|SHIFT',
    action = act.InputSelector {
      title = 'Select Split Direction',
      choices = {
        {
          label = 'Up: Open split above the current pane',
          id = 'Up',
        },
        {
          label = 'Down: Open split below the current pane',
          id = 'Down',
        },
        {
          label = 'Left: Open split to the left of the current pane',
          id = 'Left',
        },
        {
          label = 'Right: Open split to the right of the current pane',
          id = 'Right',
        },
      },
      action = wezterm.action_callback(function(window, pane, id, label)
        if not id and not label then
          return
        end

        window:perform_action(
          act.SplitPane {
            direction = id,
            size = { Percent = 50 },
          },
          pane
        )
      end)
    },
  },
  {
    -- split pane down
    key = '-',
    mods = 'LEADER',
    action = act.SplitVertical(current_pane_domain),
  },
  {
    -- split pane right
    key = '\\',
    mods = 'LEADER',
    action = act.SplitHorizontal(current_pane_domain),
  },

  {
    -- select pane by id
    key = 'q',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window1, pane1)
      local choices = {}
      for i, p in ipairs(window1:active_tab():panes()) do
        table.insert(choices, {
          id = tostring(i - 1),
          label = p:get_title(),
        })
      end

      window1:perform_action(
        act.InputSelector {
          title = 'Select Pane',
          choices = choices,
          action = wezterm.action_callback(function(window2, pane2, id, _)
            if not id then
              return
            end

            window2:perform_action(
              act.ActivatePaneById(tonumber(id, 10)),
              pane2
            )
          end)
        },
        pane1
      )
    end)
  },

  {
    -- tab navigator
    key = 'n',
    mods = 'LEADER',
    action = act.ShowTabNavigator
  },

  {
    -- spawn a new tab
    key = 't',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  {
    -- close current tab
    key = 'w',
    mods = 'LEADER',
    action = act.CloseCurrentTab { confirm = true, },
  },


  -- map pane navigation to leader->direction
  {
    key = 'h',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Left',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Down',
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Up',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = act.ActivatePaneDirection 'Right',
  },

  {
    key = 'H',
    mods = 'LEADER|SHIFT',
    action = act.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'j',
    mods = 'LEADER|SHIFT',
    action = act.AdjustPaneSize { 'Down', 5 },
  },
  {
    key = 'k',
    mods = 'LEADER|SHIFT',
    action = act.AdjustPaneSize { 'Up', 5 },
  },
  {
    key = 'l',
    mods = 'LEADER|SHIFT',
    action = act.AdjustPaneSize { 'Right', 5 },
  },
}

return config
