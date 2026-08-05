local function generic_single_display_profile()
    return {
        monitors = {
            -- Empty lists use Hyprland's fallback monitor rule.
            outputs = {},
            workspace_outputs = {},
        },
        bluetooth_device = nil,
    }
end

local function dual_display_profile()
    return {
        monitors = {
            outputs = {
                {
                    output = "HDMI-A-1",
                    mode = "1920x1080",
                    position = "0x0",
                    scale = 1,
                },
                {
                    output = "DP-2",
                    mode = "1920x1080",
                    position = "1920x0",
                    scale = 1,
                },
            },
            workspace_outputs = {
                { output = "HDMI-A-1" },
                { output = "DP-2" },
            },
        },
        bluetooth_device = nil,
    }
end

return {
    -- Works without a local override on any single-display machine.
    default_profile = "laptop",
    profiles = {
        desk = dual_display_profile(),
        laptop = generic_single_display_profile(),
    },
}
