local apps = require("modules.apps")
local constants = require("modules.constants")

return {
    {
        name = "polkit-agent",
        command = "lxqt-policykit-agent",
        binary = "lxqt-policykit-agent",
        process_match = "lxqt-policykit-agent",
        optional = true,
    },
    { name = "wallpaper", command = "wpaperd -c $HOME/.config/wpaperd/wallpaper.toml", binary = "wpaperd" },
    { name = "input-method", command = "fcitx5", binary = "fcitx5", process = "fcitx5" },
    {
        name = "cliphist-text",
        command = string.format("wl-paste --type text --watch cliphist -max-items %d store", constants.clipboard_max_items),
        binary = "wl-paste",
    },
    {
        name = "cliphist-image",
        command = string.format("wl-paste --type image --watch cliphist -max-items %d store", constants.clipboard_max_items),
        binary = "wl-paste",
    },
    { name = "udiskie", command = "udiskie", binary = "udiskie" },
    { name = "synology-drive", command = "synology-drive autostart", binary = "synology-drive" },
    { name = "hypridle", command = "hypridle", binary = "hypridle" },
    { name = "clash-verge", command = "clash-verge", binary = "clash-verge" },
}
