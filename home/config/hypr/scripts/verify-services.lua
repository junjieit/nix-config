local config_dir = assert(arg[1], "usage: verify-services.lua CONFIG_DIR")
package.path = config_dir .. "/?.lua;" .. package.path

local services = require("modules.services")
local failed = false

local function fail(message)
    io.stderr:write(message .. "\n")
    failed = true
end

local function warn(message)
    io.stderr:write("Warning: " .. message .. "\n")
end

for _, service in ipairs(services) do
    if service.binary and not os.execute("command -v " .. service.binary .. " >/dev/null 2>&1") then
        local message = "Missing command for " .. service.name .. ": " .. service.binary
        if service.optional then warn(message) else fail(message) end
    end
    if service.path then
        local file = io.open(service.path, "r")
        if not file then
            local message = "Missing executable for " .. service.name .. ": " .. service.path
            if service.optional then warn(message) else fail(message) end
        else
            file:close()
        end
    end
end

os.exit(failed and 1 or 0)
