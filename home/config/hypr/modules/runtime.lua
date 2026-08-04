local constants = require("modules.constants")

local function profile_matches_connected_outputs(profile)
    local outputs = profile.monitors.outputs
    if #outputs < 2 then
        return false
    end

    local connected = {}
    for _, monitor in ipairs(hl.get_monitors()) do
        connected[monitor.name] = true
    end
    for _, output in ipairs(outputs) do
        if not connected[output.output] then
            return false
        end
    end
    return true
end

return function(workspaces)
    local function refresh_profile()
        local desired = constants.profile_name
        if constants.profiles.desk and profile_matches_connected_outputs(constants.profiles.desk) then
            desired = "desk"
        elseif constants.profiles.laptop then
            desired = "laptop"
        end

        if workspaces.activate(desired) then
            hl.notification.create({
                text = "Hyprland profile: " .. desired,
                timeout = 2000,
                icon = 2,
            })
        end
    end

    -- hl.timer crashes Hyprland 0.56.1's --verify-config path, so refresh
    -- directly on topology events until that upstream issue is resolved.
    hl.on("hyprland.start", refresh_profile)
    hl.on("monitor.added", refresh_profile)
    hl.on("monitor.removed", refresh_profile)
end
