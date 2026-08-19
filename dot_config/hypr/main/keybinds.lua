---------------------
---- KEYBINDINGS ----
---------------------

-- Keys are bound by keycode (`code:NN`) rather than by symbol, so the binds
-- keep working on non-latin / alternative keyboard layouts.
-- Keycodes are evdev codes + 8 (see /usr/include/linux/input-event-codes.h).

local programs = require("main.programs")

local terminal    = programs.terminal
local fileManager = programs.fileManager
local menu        = programs.menu
local lock        = programs.lock

local workspaces  = require("scripts.workspaces")

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + code:28", hl.dsp.exec_cmd(terminal))                    -- T
local closeWindowBind = hl.bind(mainMod .. " + code:54", hl.dsp.window.close()) -- C
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + code:58", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")) -- M
hl.bind(mainMod .. " + code:41", hl.dsp.exec_cmd(fileManager))                 -- F
hl.bind(mainMod .. " + code:55", hl.dsp.window.float({ action = "toggle" }))   -- V
hl.bind(mainMod .. " + code:38", hl.dsp.exec_cmd(menu))                        -- A
hl.bind(mainMod .. " + code:33", hl.dsp.window.pseudo())                       -- P
hl.bind(mainMod .. " + code:44", hl.dsp.layout("togglesplit"))                 -- J, dwindle only
hl.bind(mainMod .. " + code:56", hl.dsp.exec_cmd([[cliphist list | wofi --dmenu --pre-display-cmd "echo '%s' | cut -f 2" | cliphist decode | wl-copy]])) -- B
hl.bind(mainMod .. " + code:46", hl.dsp.exec_cmd(lock))                        -- L
hl.bind(mainMod .. " + code:24", workspaces) -- Q, see scripts/workspaces.lua

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + code:113", hl.dsp.focus({ direction = "left" }))        -- left
hl.bind(mainMod .. " + code:114", hl.dsp.focus({ direction = "right" }))       -- right
hl.bind(mainMod .. " + code:111", hl.dsp.focus({ direction = "up" }))          -- up
hl.bind(mainMod .. " + code:116", hl.dsp.focus({ direction = "down" }))        -- down

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
-- Keycodes of the number row: 1..9 then 0 (10 maps to key 0)
local numberRow = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }
for i = 1, 10 do
    local key = "code:" .. numberRow[i]
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + code:39",         hl.dsp.workspace.toggle_special("magic"))                 -- S
hl.bind(mainMod .. " + SHIFT + code:39", hl.dsp.window.move({ workspace = "special:magic" }))      -- S

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
-- Kept as XF86 symbols: they are layout-independent already, and XF86AudioMicMute
-- (keycode 256) is outside the range xkb can address with `code:`.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("CTRL + code:65", hl.dsp.exec_cmd("playerctl play-pause")) -- SPACE

-- Screenshot a selected region to the clipboard (requires grim + slurp)
hl.bind(mainMod .. " + code:107", hl.dsp.exec_cmd([[grim -g "$(slurp)" - | wl-copy]])) -- PRINT
