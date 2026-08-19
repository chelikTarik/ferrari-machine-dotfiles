#!/usr/bin/env python3
import os
import socket
import sys
import time
import subprocess
import json

# Serial -> monique profile. Monitors not listed here are unknown to us.
PROFILE_BY_SERIAL = {
    'WUBP6HA006205': 'home',
    'Y1H5T1A633KL': 'work',
    'YPPY098C2T3L': 'work',
}
BUILTIN_PREFIX = 'eDP'
FALLBACK_PROFILE = 'tmp'

MONITOR_EVENTS = (
    'monitoradded',
    'monitoraddedv2',
    'monitorremoved',
    'monitorremovedv2',
)
DEBOUNCE = 0.5
# Give monique's monitor changes a moment to land before re-pinning workspaces.
SETTLE_DELAY = 0.3
WORKSPACES_EVAL = 'return require("main.workspaces").apply()'
RECV_TIMEOUT = 0.5
CONNECT_RETRIES = 10
CONNECT_DELAY = 0.5


def env(name):
    try:
        return os.environ[name]
    except KeyError:
        sys.exit(f"{name} is not set - is this running inside a Hyprland session?")


def get_monitors():
    """All connected monitors, including ones a profile has disabled."""
    result = subprocess.run(
        ["hyprctl", "monitors", "all", "-j"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"hyprctl failed ({result.returncode}): {result.stderr.strip()}",
              file=sys.stderr, flush=True)
        return None
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as e:
        print(f"could not parse hyprctl output: {e}", file=sys.stderr, flush=True)
        return None


def pick_profile(monitors):
    """First known serial wins; laptop-only falls back; anything else is left alone."""
    for monitor in monitors:
        profile = PROFILE_BY_SERIAL.get(monitor['serial'])
        if profile:
            return profile

    externals = [m for m in monitors if not m['name'].startswith(BUILTIN_PREFIX)]
    if not externals:
        return FALLBACK_PROFILE

    return None


def current_profile():
    result = subprocess.run(
        ["monique", "--current-profile"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        return None
    return result.stdout.strip()


def apply_profile(name):
    if name == current_profile():
        return

    result = subprocess.run(
        ["monique", "--switch-profile", name],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"monique failed ({result.returncode}): {result.stderr.strip()}",
              file=sys.stderr, flush=True)


def apply_workspaces():
    """Re-pin workspaces onto whatever monitors are enabled now."""
    result = subprocess.run(
        ["hyprctl", "eval", WORKSPACES_EVAL],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"hyprctl eval failed ({result.returncode}): {result.stderr.strip()}",
              file=sys.stderr, flush=True)


def evaluate():
    monitors = get_monitors()
    if monitors is None:
        return

    profile = pick_profile(monitors)
    if profile is None:
        return

    apply_profile(profile)

    time.sleep(SETTLE_DELAY)
    apply_workspaces()


def connect(path):
    """Hyprland may still be bringing the socket up when exec-once fires."""
    for attempt in range(CONNECT_RETRIES):
        try:
            stream = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            stream.connect(path)
            return stream
        except (FileNotFoundError, ConnectionRefusedError) as e:
            if attempt == CONNECT_RETRIES - 1:
                sys.exit(f"could not connect to {path}: {e}")
            time.sleep(CONNECT_DELAY)


runtime_dir = env('XDG_RUNTIME_DIR')
his = env('HYPRLAND_INSTANCE_SIGNATURE')
path = f"{runtime_dir}/hypr/{his}/.socket2.sock"

stream = connect(path)
stream.settimeout(RECV_TIMEOUT)

# Monitors already present at launch never emit monitoradded, so settle them now.
# Done after connecting so events during the initial apply are not missed.
evaluate()

buffer = ''
last_event_time = 0
event_detected = False

while True:
    try:
        chunk = stream.recv(1024)
        if not chunk:
            break

        buffer += chunk.decode('utf-8')
        parsed = buffer.split('\n')
        buffer = parsed[-1]

        # parsed[-1] is the incomplete tail, kept in buffer for the next read.
        for event in parsed[:-1]:
            if event.split('>>')[0] in MONITOR_EVENTS:
                last_event_time = time.time()
                event_detected = True

    except socket.timeout:
        pass

    if event_detected and time.time() - last_event_time >= DEBOUNCE:
        event_detected = False
        evaluate()

stream.close()
