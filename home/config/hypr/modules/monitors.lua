local constants = require("modules.constants")

-- Use the preferred mode for unlisted outputs, then declare all known profiles.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

local declared_outputs = {}
for _, profile in pairs(constants.profiles) do
    for _, monitor in ipairs(profile.monitors.outputs) do
        if not declared_outputs[monitor.output] then
            hl.monitor(monitor)
            declared_outputs[monitor.output] = true
        end
    end
end
