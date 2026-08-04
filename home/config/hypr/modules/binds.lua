local constants = require("modules.constants")
local apps = require("modules.apps")
local main_mod = constants.main_mod
local alt_mod = constants.alt_mod

hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd(apps.terminal))
hl.bind(main_mod .. " + T", hl.dsp.exec_cmd(apps.terminal))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + M", hl.dsp.exit())
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(apps.file_manager))
hl.bind(main_mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(apps.app_launcher))
hl.bind(main_mod .. " + P", hl.dsp.window.pseudo())

-- Resize mode keeps arrow-key resizing out of the global keymap.
hl.bind(main_mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
    hl.bind("left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
    hl.bind("up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
    hl.bind("down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("catchall", hl.dsp.submap("reset"))
end)

hl.bind(main_mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + down", hl.dsp.focus({ direction = "down" }))

for group = 1, constants.workspace_group_count do
    hl.bind(main_mod .. " + CTRL + " .. group, hl.dsp.exec_cmd(constants.workspace_group .. " switch " .. group))
end

for workspace = 1, constants.workspaces_per_group do
    local key = workspace % constants.workspaces_per_group
    hl.bind(main_mod .. " + " .. key, hl.dsp.exec_cmd(constants.workspace_group .. " workspace " .. workspace))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.exec_cmd(constants.workspace_group .. " move " .. workspace))
end

hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(alt_mod .. " + SHIFT + E", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
hl.bind(main_mod .. " + V", hl.dsp.exec_cmd(apps.clipboard_menu))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd(apps.lock_screen))
hl.bind(main_mod .. " + C", hl.dsp.exec_cmd(apps.editor))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("mpc -q toggle"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("mpc -q prev"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("mpc -q next"), { locked = true })
