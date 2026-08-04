hl.window_rule({
    name = "keepassxc-workspace",
    match = { class = "org.keepassxc.KeePassXC" },
    workspace = 6,
})

hl.window_rule({
    name = "slack-workspace",
    match = { class = "slack" },
    workspace = 3,
})
