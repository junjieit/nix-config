local function desktop_theme()
    local state_root = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
    local state_file = io.open(state_root .. "/desktop-theme/current", "r")
    if not state_file then
        return "dark"
    end
    local theme = state_file:read("*l")
    state_file:close()
    return theme == "light" and "light" or "dark"
end

local active_border, inactive_border
if desktop_theme() == "light" then
    active_border = "rgba(0f766eff)"
    inactive_border = "rgba(00000000)"
else
    active_border = "rgba(34d399ff)"
    inactive_border = "rgba(00000000)"
end

hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 15,
        border_size = 1,
        col = {
            active_border = active_border,
            inactive_border = inactive_border,
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        active_opacity = 1.0,
        inactive_opacity = 0.87,
        shadow = {
            enabled = true,
            range = 12,
            render_power = 3,
            color = "rgba(00000044)",
        },
        blur = { enabled = true, size = 5, passes = 2, new_optimizations = true },
    },
    -- Work around amdgpu atomic page-flip stalls; retest after graphics-stack updates.
    cursor = {
        no_hardware_cursors = true,
    },
    render = {
        direct_scanout = 0,
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
})

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
