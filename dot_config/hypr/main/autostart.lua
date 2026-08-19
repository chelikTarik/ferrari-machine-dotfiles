-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- local programs = require("main.programs")
--
hl.on("hyprland.start", function ()
  hl.exec_cmd("hypridle")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("waybar")

  -- Clipboard-history daemon
  hl.exec_cmd("wl-paste --watch cliphist store")
  -- Listens for events, applies the relevant monitor configuration, and triggers a workspace re-pin.
  hl.exec_cmd("python3 " .. os.getenv("HOME") .. "/.config/hypr/scripts/monitors_switcher.py")
end)

