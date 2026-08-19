--------------------
---- WORKSPACES ----
--------------------

-- Workspace -> monitor assignment, decided from the monitors that are
-- currently enabled instead of being hardcoded per machine.
--
-- Runs when the config loads, and is safe to re-run at any time:
--
--     hyprctl eval 'return require("main.workspaces").apply()'
--
-- which prints the layout it settled on. Call that from
-- scripts/monitors_switcher.py right after switching the monique profile.

-- Monitors we know about. `serial` is compared exactly, `name` is a Lua
-- pattern matched against the connector name.
local ROLES = {
    laptop = { name   = "^eDP" },
    home   = { serial = "WUBP6HA006205" }, -- AOC 24G2W1G3
    work_l = { serial = "YPPY098C2T3L" },  -- Dell U2412M
    work_r = { serial = "Y1H5T1A633KL" },  -- Dell U2412M
}

-- The first layout whose `needs` roles are all present wins, so order matters:
-- most specific first. Roles that aren't connected are skipped, so a layout
-- degrades gracefully instead of pinning workspaces to a dead output.
local LAYOUTS = {
    {
        name  = "work",
        needs = { "work_l", "work_r" },
        place = {
            { role = "work_l", workspaces = { 1, 2 } },
            { role = "work_r", workspaces = { 3, 4 } },
            { role = "laptop", workspaces = { 5 } },
        },
    },
    {
        name  = "work-left",
        needs = { "work_l" },
        place = {
            { role = "work_l", workspaces = { 3 } },
            { role = "laptop", workspaces = { 1, 2 } },
        },
    },
    {
        name  = "work-right",
        needs = { "work_r" },
        place = {
            { role = "work_r", workspaces = { 3 } },
            { role = "laptop", workspaces = { 1, 2 } },
        },
    },
    {
        name  = "home",
        needs = { "home" },
        place = {
            { role = "home",   workspaces = { 3 } },
            { role = "laptop", workspaces = { 1, 2 } },
        },
    },
    {
        name  = "laptop",
        needs = {},
        place = {
            { role = "laptop", workspaces = { 1, 2, 3, 4, 5 } },
        },
    },
}

-- role -> connector name, for every enabled monitor we recognise
local function detect()
    local present = {}

    for _, mon in ipairs(hl.get_monitors()) do
        for role, spec in pairs(ROLES) do
            local hit = (spec.serial and mon.serial == spec.serial)
                     or (spec.name and mon.name:match(spec.name))
            if hit then
                present[role] = mon.name
            end
        end
    end

    return present
end

local function pick(present)
    for _, layout in ipairs(LAYOUTS) do
        local ok = true
        for _, role in ipairs(layout.needs) do
            if not present[role] then
                ok = false
                break
            end
        end
        if ok then
            return layout
        end
    end
end

local function apply()
    local present = detect()

    -- Nothing recognised yet (e.g. the config parses before outputs exist on
    -- the very first start) -- leave the current rules alone.
    if not next(present) then
        return nil
    end

    local layout = pick(present)
    if not layout then
        return nil
    end

    -- Workspaces that already exist need moving; a rule alone only decides
    -- where a workspace is created.
    local existing = {}
    for _, ws in ipairs(hl.get_workspaces()) do
        existing[ws.id] = true
    end

    for _, entry in ipairs(layout.place) do
        local output = present[entry.role]
        if output then
            for _, id in ipairs(entry.workspaces) do
                hl.workspace_rule({ workspace = tostring(id), monitor = output })
                if existing[id] then
                    hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = output }))
                end
            end
        end
    end

    return layout.name
end

apply()

-- Outputs exist by the time Hyprland is up, so settle again once it is.
hl.on("hyprland.start", apply)

return {
    apply  = apply,
    detect = detect,
}
