-- ── Hyprland Lua Config ────────────────────────────────────
-- Entry point: ~/.config/hypr/hyprland.lua

hl.config({
    input = {
        kb_layout = "it",
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
    },
    animations = {
        enabled = true,
    },
})

-- Preload kitty for faster terminal opening
hl.on("hyprland.start", function()
    hl.exec_cmd("kitty")
    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- AGS shell
    hl.exec_cmd("$HOME/.config/hypr/scripts/start-ags.sh")
end)

-- Special workspace animations (slide from bottom)
hl.curve("specialDecel", {
    type = "bezier",
    points = { { 0.05, 0.7 }, { 0.1, 1 } },
})
hl.animation({
    leaf = "specialWorkspaceIn",
    enabled = true,
    speed = 3,
    bezier = "specialDecel",
    style = "slidevert",
})
hl.animation({
    leaf = "specialWorkspaceOut",
    enabled = true,
    speed = 3,
    bezier = "specialDecel",
    style = "slidevert",
})

require("keybinds")
require("layers")
require("rules")