local constants = require("modules.constants")
local apps = require("modules.apps")
local services = require("modules.services")

hl.on("hyprland.start", function()
    for _, service in ipairs(services) do
        hl.exec_cmd(service.command)
    end

    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE DBUS_SESSION_BUS_ADDRESS XDG_CURRENT_DESKTOP; bash $HOME/.config/hypr/scripts/desktop-theme auto")

    hl.exec_cmd(apps.password_manager)

    if constants.bluetooth_device then
        local device = constants.bluetooth_device
        hl.exec_cmd("bluetoothctl info " .. device .. " >/dev/null 2>&1 && bluetoothctl connect " .. device)
    end
end)
