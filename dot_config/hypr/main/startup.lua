-------------------
---- STARTUP -------
-------------------

-- Session startup: launch the usual apps, each pinned to its workspace.
-- Bound to SUPER + Q in main/keybinds.lua.

local apps = {
    { workspace = 1, cmd = "google-chat-linux" },
    { workspace = 1, cmd = "slack" },
    { workspace = 2, cmd = "brave" },
    { workspace = 3, cmd = "phpstorm" },
}

return function()
    for _, app in ipairs(apps) do
        hl.exec_cmd(app.cmd, { workspace = app.workspace .. " silent" })
    end

    -- Land on workspace 1 when done
    hl.dispatch(hl.dsp.focus({ workspace = 1 }))
end
