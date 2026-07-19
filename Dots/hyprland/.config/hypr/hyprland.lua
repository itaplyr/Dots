hl.config({
    input = {
        kb_layout = "it",
        follow_mouse = 1,
        kb_options = "caps:none",
        touchpad = {
            natural_scroll = true,
        },
    },
    animations = {
        enabled = true,
    },
    misc = {
	initial_workspace_tracking = 2,
    },
})


hl.on("hyprland.start", function()
    
    --// Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    --// General Utils
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaybg -i ~/.config/hypr/hyprland/wallpaper.png")
end)

require("hyprland.keybinds")
require("hyprland.rules")
require("hyprland.animations")
