-- Optional local override. Copy this file to local.lua only for machine-specific values.
local left = {
    output = "HDMI-A-1",
    mode = "1920x1080",
    position = "0x0",
    scale = 1,
}

local right = {
    output = "DP-2",
    mode = "1920x1080",
    position = "1920x0",
    scale = 1,
}

return {
    default_profile = "desk",
    profiles = {
        desk = {
            monitors = {
                left = left,
                right = right,
                outputs = { right, left },
                workspace_outputs = { left, right },
            },
            bluetooth_device = nil,
        },
    },
}
