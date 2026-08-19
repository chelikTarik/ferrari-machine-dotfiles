----------------
---- CURSOR ----
----------------

-- Fix for the monitor connection issue (see also the systemd loader config
-- for boot). Software cursors avoid the hardware cursor plane going stale
-- when outputs are hotplugged.
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})
