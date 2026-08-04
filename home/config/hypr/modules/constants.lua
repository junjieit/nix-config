local home_dir = assert(os.getenv("HOME"), "HOME must be set for this Hyprland configuration")
local xdg_config_home = os.getenv("XDG_CONFIG_HOME") or (home_dir .. "/.config")
local config_dir = xdg_config_home .. "/hypr"
local config = require("modules.defaults")

local function is_list(value)
    return type(value) == "table" and #value > 0
end

local function merge(target, override)
    for key, value in pairs(override) do
        if type(value) == "table" and type(target[key]) == "table" and not is_list(value) then
            merge(target[key], value)
        else
            target[key] = value
        end
    end
end

local ok, local_override = pcall(require, "modules.local")
if ok then
    merge(config, local_override)
elseif not string.find(local_override, "module 'modules.local' not found", 1, true) then
    error(local_override)
end

local profile_name = os.getenv("HYPRLAND_PROFILE") or config.default_profile
local profile = assert(config.profiles[profile_name], "unknown Hyprland profile: " .. tostring(profile_name))

local workspaces_per_group = 10
assert(workspaces_per_group == 10, "workspace key bindings require exactly 10 logical workspaces")

return {
    config_dir = config_dir,
    main_mod = "SUPER",
    alt_mod = "ALT",
    workspace_group = config_dir .. "/scripts/workspace-group",
    workspaces_per_group = workspaces_per_group,
    workspace_group_count = 5,
    clipboard_max_items = 100,
    profile_name = profile_name,
    profiles = config.profiles,
    monitors = profile.monitors,
    workspace_outputs = profile.monitors.workspace_outputs or profile.monitors.outputs,
    bluetooth_device = profile.bluetooth_device,
}
