--------------------
---- WORKSPACES ----
--------------------

-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Pin workspaces to a monitor. `monitor` takes the same selectors as
-- hl.monitor: a connector name ("eDP-1") or "desc:<monitor description>".

-- Examples from the old config, kept for reference:
-- hl.workspace_rule({ workspace = "name:1", monitor = "HDMI-6" })
-- hl.workspace_rule({ workspace = "1", monitor = "desc:Dell Inc. DELL U2412M YPPY098C2T3L" })
-- hl.workspace_rule({ workspace = "2", monitor = "desc:Dell Inc. DELL U2412M YPPY098C2T3L" })
-- hl.workspace_rule({ workspace = "3", monitor = "desc:Dell Inc. DELL U2412M Y1H5T1A633KL" })
-- hl.workspace_rule({ workspace = "4", monitor = "desc:Dell Inc. DELL U2412M Y1H5T1A633KL" })

-- home

-- Laptop screen
hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1" })

-- External monitor
-- NOTE: workspaces 1 and 2 are claimed by both blocks. A workspace can only
-- live on one monitor, and the last rule wins, so as written 1 and 2 end up on
-- the AOC and the eDP-1 rules above have no effect. Drop one side to make the
-- split explicit (e.g. keep 1-2 on eDP-1 and start this block at 3).
hl.workspace_rule({ workspace = "1", monitor = "desc:AOC 24G2W1G3- WUBP6HA006205" })
hl.workspace_rule({ workspace = "2", monitor = "desc:AOC 24G2W1G3- WUBP6HA006205" })
hl.workspace_rule({ workspace = "3", monitor = "desc:AOC 24G2W1G3- WUBP6HA006205" })
hl.workspace_rule({ workspace = "4", monitor = "desc:AOC 24G2W1G3- WUBP6HA006205" })
