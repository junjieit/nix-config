# Hyprland Lua Configuration

This configuration targets Hyprland 0.55 and later. `hyprland.lua` is the only entry point; it loads the modules in `modules/`.

## Layout

- `defaults.lua`: portable default profiles, usable without any local file.
- `constants.lua`: portable paths, modifiers, workspace limits, clipboard retention, and local override merging.
- `monitors.lua`: registers the display layout declared in `local.lua`.
- `environment.lua`, `appearance.lua`, `input.lua`, `rules.lua`: environment, visual settings, input settings, and window rules.
- `apps.lua`: commands reused by key bindings and startup services.
- `services.lua`: the single source for persistent session services, started directly when Hyprland starts.
- `workspaces.lua`, `binds.lua`: workspace routing and keyboard/mouse bindings.
- `runtime.lua`: monitor events that switch workspace routing between desk and laptop profiles.
- `layouts.lua`: registers an optional `balanced` custom layout without changing the default dwindle layout.
- `autostart.lua`: categorized startup commands.
- `local.lua`: optional machine-specific display and Bluetooth overrides; ignored by Git.

`modules/local.example.lua` documents the optional override shape. A machine without `modules/local.lua` uses the generic single-display `laptop` profile. Create that file only to override values such as output names, Bluetooth devices, or `default_profile`. Set `HYPRLAND_PROFILE` to select a profile for one session; otherwise `default_profile` is used.

The built-in `laptop` profile deliberately has no named outputs. On a single-display machine this lets Hyprland use its fallback monitor rule and leaves every workspace on that display.

Persistent services use the Lua equivalent of `exec-once`: the `hyprland.start` callback calls `hl.exec_cmd` once per session. The KDE Polkit agent remains optional until `polkit-kde-agent` is installed.

## Validation

Run the following after changing the configuration:

```sh
./scripts/verify-config
```

The validation also runs the workspace-group test suite. Lua language servers can use `.luarc.json` and the installed Hyprland stubs for `hl.*` completions.

ClipHist retains at most 100 entries, configured through `clipboard_max_items` in `constants.lua`. The original hyprlang configuration is retained as `hyprland.conf.bak`.

`SUPER + R` enters resize mode; arrow keys resize the active window, and `Escape` leaves the mode.
