-- [[[ Workspace Rules ]]]
hl.workspace_rule({ workspace = "s[true]", gaps_out = 15, no_rounding = true})
hl.workspace_rule({ workspace = "s[false]", gaps_out = 7, gaps_in = 2})

-- [[[ Window Rules ]]]
hl.window_rule({ match = { class = "kitty" }, opacity = "0.9", no_blur = true})

-- [[[ Layer Rules ]]]
hl.layer_rule({
    match = {
        namespace = "launcher"
    },
    blur = true,
    ignore_alpha = 0,
    dim_around = true,
    no_anim = true,
})

hl.layer_rule({
    match = {
        namespace = "project-selector"
    },
    blur = true,
    ignore_alpha = 0,
    dim_around = true,
    no_anim = true
})
