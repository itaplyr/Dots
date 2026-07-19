-- [[[ Special workspace ]]]
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
