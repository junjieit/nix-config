local constants = require("modules.constants")
local apps = require("modules.apps")
local services = require("modules.services")

hl.on("hyprland.start", function()
    for _, service in ipairs(services) do
        hl.exec_cmd(service.command)
    end

    hl.exec_cmd(apps.password_manager)

    if constants.bluetooth_device then
        local device = constants.bluetooth_device
        hl.exec_cmd("bluetoothctl info " .. device .. " >/dev/null 2>&1 && bluetoothctl connect " .. device)
    end
end)
