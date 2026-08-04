local constants = require("modules.constants")

local rules_by_profile = {}

for name, profile in pairs(constants.profiles) do
    local handles = {}
    local outputs = profile.monitors.workspace_outputs or profile.monitors.outputs

    -- Single-output profiles need no explicit monitor rules: Hyprland places
    -- every workspace on the active display. Multi-output profiles round-robin.
    if #outputs > 1 then
        for group = 0, constants.workspace_group_count - 1 do
            for logical = 1, constants.workspaces_per_group do
                local workspace = group * constants.workspaces_per_group + logical
                local output = outputs[(logical - 1) % #outputs + 1]
                table.insert(handles, hl.workspace_rule({
                    workspace = tostring(workspace),
                    monitor = output.output,
                    enabled = name == constants.profile_name,
                }))
            end
        end
    end

    rules_by_profile[name] = handles
end

local active_profile = constants.profile_name

local function activate(profile_name)
    if not rules_by_profile[profile_name] or profile_name == active_profile then
        return false
    end

    for name, handles in pairs(rules_by_profile) do
        for _, handle in ipairs(handles) do
            handle:set_enabled(name == profile_name)
        end
    end

    active_profile = profile_name
    return true
end

return { activate = activate, active_profile = function() return active_profile end }
