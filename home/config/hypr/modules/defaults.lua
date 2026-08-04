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

return {
    -- Works without a local override on any single-display machine.
    default_profile = "laptop",
    profiles = {
        desk = generic_single_display_profile(),
        laptop = generic_single_display_profile(),
    },
}
