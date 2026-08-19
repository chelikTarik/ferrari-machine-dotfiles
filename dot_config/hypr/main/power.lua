---------------
---- POWER ----
---------------

-- Lid handling: turn the built-in screen off when the lid closes and back on
-- when it opens, then let main/workspaces.lua re-pin workspaces to whatever
-- is left enabled.

local workspaces = require("main.workspaces")

local LAPTOP_OUTPUT = "eDP-1"
local LID_SWITCH    = "Lid Switch"

-- The monitor list takes a moment to settle after enabling/disabling an
-- output, so re-pin workspaces just after rather than in the same breath.
local SETTLE_MS = 300

local function reapply_workspaces()
    hl.timer(function()
        workspaces.apply()
    end, { timeout = SETTLE_MS, type = "oneshot" })
end

-- True when something other than the built-in panel is on.
local function has_external()
    for _, mon in ipairs(hl.get_monitors()) do
        if not mon.name:match("^eDP") then
            return true
        end
    end
    return false
end

local function set_laptop_screen(enabled)
    if enabled then
        -- `disabled = false` is required, not decoration: hl.monitor merges
        -- into the existing rule for this output, so without it the rule
        -- written by the disable branch below keeps the panel off.
        hl.monitor({
            output   = LAPTOP_OUTPUT,
            disabled = false,
            mode     = "preferred",
            position = "auto",
            scale    = 1,
        })
    else
        hl.monitor({ output = LAPTOP_OUTPUT, disabled = true })
    end

    reapply_workspaces()
end

-- Lid closed. Keep the panel on if it is the only screen -- disabling it would
-- leave the session with no output at all; hypridle handles that case.
hl.bind("switch:on:" .. LID_SWITCH, function()
    if has_external() then
        set_laptop_screen(false)
    end
end, { locked = true })

-- Lid opened.
hl.bind("switch:off:" .. LID_SWITCH, function()
    set_laptop_screen(true)
end, { locked = true })
