-- ── Keybinds ──────────────────────────────────────────────
-- Custom keybinds for Hyprland (Lua config)
-- SUPER+Q = close window
-- SUPER+Enter = kitty terminal

local M = {}

M.bind = {
    -- Window management
    { "SUPER", "Q", "killactive" },
    { "SUPER", "Escape", "exit" },

    -- Launchers
    { "SUPER", "Return", "exec, kitty" },

    -- Focus movement
    { "SUPER", "h", "movefocus, l" },
    { "SUPER", "l", "movefocus, r" },
    { "SUPER", "k", "movefocus, u" },
    { "SUPER", "j", "movefocus, d" },

    -- Window switching
    { "SUPER", "Tab", "overview:toggle" },

    -- Workspaces
    { "SUPER", "1", "workspace, 1" },
    { "SUPER", "2", "workspace, 2" },
    { "SUPER", "3", "workspace, 3" },
    { "SUPER", "4", "workspace, 4" },
    { "SUPER", "5", "workspace, 5" },
    { "SUPER", "6", "workspace, 6" },
    { "SUPER", "7", "workspace, 7" },
    { "SUPER", "8", "workspace, 8" },
    { "SUPER", "9", "workspace, 9" },
    { "SUPER", "0", "workspace, 10" },

    -- Move windows to workspaces
    { "SUPER SHIFT", "1", "movetoworkspace, 1" },
    { "SUPER SHIFT", "2", "movetoworkspace, 2" },
    { "SUPER SHIFT", "3", "movetoworkspace, 3" },
    { "SUPER SHIFT", "4", "movetoworkspace, 4" },
    { "SUPER SHIFT", "5", "movetoworkspace, 5" },
    { "SUPER SHIFT", "6", "movetoworkspace, 6" },
    { "SUPER SHIFT", "7", "movetoworkspace, 7" },
    { "SUPER SHIFT", "8", "movetoworkspace, 8" },
    { "SUPER SHIFT", "9", "movetoworkspace, 9" },
    { "SUPER SHIFT", "0", "movetoworkspace, 10" },

    -- Layout
    { "SUPER", "F", "fullscreen" },
    { "SUPER", "Space", "togglefloating" },
    { "SUPER", "P", "pseudo" },
    { "SUPER", "J", "togglesplit" },

    -- Resize
    { "SUPER CTRL", "h", "resizeactive, -20 0" },
    { "SUPER CTRL", "l", "resizeactive, 20 0" },
    { "SUPER CTRL", "k", "resizeactive, 0 -20" },
    { "SUPER CTRL", "j", "resizeactive, 0 20" },
}

return M
