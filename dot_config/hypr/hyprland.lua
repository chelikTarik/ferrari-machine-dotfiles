--------------------------------------------------------------------
---- Hyprland config entry point                                 ----
---- The actual configuration lives in ~/.config/hypr/main/*.lua ----
--------------------------------------------------------------------

-- `require` resolves relative to this file's directory and every required
-- file is tracked, so edits to main/*.lua trigger a config reload too.

require("main.cursor")
require("main.monitors")
require("main.workspaces")
require("main.autostart")
require("main.env")
require("main.permissions")
require("main.look-and-feel")
require("main.animations")
require("main.layouts")
require("main.misc")
require("main.input")
require("main.power")
require("main.keybinds")
require("main.windowrules")

-- main.programs (terminal / file manager / menu) is pulled in by the
-- sections that need it.
