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

  -- clipboard-history daemon
  hl.exec_cmd("wl-paste --watch cliphist store")
end)

