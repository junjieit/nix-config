-- Hyprland 0.55+ configuration entry point.
-- Keep modules declarative: they register configuration with the global `hl` API.

require("modules.monitors")
require("modules.environment")
require("modules.appearance")
require("modules.input")
require("modules.layouts")
local workspaces = require("modules.workspaces")
require("modules.rules")
require("modules.binds")
require("modules.autostart")
require("modules.runtime")(workspaces)
