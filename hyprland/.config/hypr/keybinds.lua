-- ── Keybinds ──────────────────────────────────────────────
-- Uses Hyprland Lua API (hl.bind)

-- Window management
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Window: Close" })
hl.bind("SUPER + Escape", hl.dsp.exit(), { description = "Session: Exit" })

-- Mouse window management
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })

-- Launchers
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"), { description = "App: Terminal" })
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/toggle-fuzzel.sh"), { description = "App: Launcher" })
hl.bind("SUPER + V", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/clipboard-manager.sh"), { description = "App: Clipboard" })

-- Focus movement (vim-style)
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }), { description = "Focus: Left" })
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }), { description = "Focus: Right" })
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }), { description = "Focus: Up" })
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }), { description = "Focus: Down" })

-- Window movement
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "l" }), { description = "Window: Move Left" })
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "r" }), { description = "Window: Move Right" })
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "u" }), { description = "Window: Move Up" })
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "d" }), { description = "Window: Move Down" })

-- Layout
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Window: Fullscreen" })
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Toggle Float" })
hl.bind("SUPER + P", hl.dsp.window.pin(), { description = "Window: Pin" })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Layout: Toggle Split" })

-- Workspaces
for i = 1, 10 do
    local ws = i % 10
    hl.bind("SUPER + " .. ws, function()
        hl.dispatch(hl.dsp.focus({ workspace = i }))
    end, { description = "Workspace: Focus " .. i })

    hl.bind("SUPER + SHIFT + " .. ws, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = true }))
    end, { description = "Workspace: Move to " .. i })

    hl.bind("SUPER + ALT + " .. ws, function()
        hl.dispatch(hl.dsp.window.move({ workspace = i, follow = false }))
    end, { description = "Workspace: Send to " .. i })
end

-- Special workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special(), { description = "Workspace: Toggle Special" })
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false }), { description = "Window: Send to Special" })

-- Resize
hl.bind("SUPER + CTRL + H", hl.dsp.layout("splitratio -0.1"), { repeating = true, description = "Layout: Shrink" })
hl.bind("SUPER + CTRL + L", hl.dsp.layout("splitratio +0.1"), { repeating = true, description = "Layout: Grow" })

-- AGS Sidebars
hl.bind("SUPER + A", hl.dsp.exec_cmd("ags toggle sidebar-left"), { description = "Shell: Toggle Left Sidebar" })
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd("ags toggle sidebar-right"), { description = "Shell: Toggle Right Sidebar" })
