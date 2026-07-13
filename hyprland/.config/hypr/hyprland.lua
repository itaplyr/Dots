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
})

require("keybinds")
