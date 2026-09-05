-- groups not working
-- shift mapping doesn't works
-- unable to resize windows
-- unable to send apps to another workspace using alt without moving with it

local terminal = "kitty"
local fileManager = "pcmanfm-qt"
local menu = "fuzzel"
local mainMod = "SUPER"
local altMod = "ALT"

-- Core Executables
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("hyprlock && systemctl restart hyprlock-sleep.service"))
hl.bind(altMod .. " + X", hl.dsp.exec_cmd("hyprlock && systemctl restart hyprlock-sleep.service"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))

-- Custom Scripts & Menus
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("~/.config/waybar/scripts/wifi-menu.sh"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("~/.config/waybar/scripts/power-menu.sh"))
hl.bind(
  altMod .. " + S",
  hl.dsp.exec_cmd(
    "source ~/codes/python/scripts/imgtotxt/.venv/bin/activate && python ~/codes/python/scripts/imgtotxt/main.py && deactivate"
  )
)

-- Window Management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + BackSpace", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(altMod .. " + Return", hl.dsp.window.fullscreen())
hl.bind("F11", hl.dsp.window.fullscreen())

-- Group Management
hl.bind(mainMod .. " + G", hl.dsp.group.lock_active("toggle"))
hl.bind(altMod .. " + G", hl.dsp.group.toggle())
hl.bind(altMod .. " + Tab", hl.dsp.group.next())
hl.bind(altMod .. " + SHIFT + Tab", hl.dsp.group.prev())

-- Utilities (Clipboard, Notifications, Wallpapers, Sunset, Emoji)
hl.bind(
  altMod .. " + V",
  hl.dsp.exec_cmd(
    [[cliphist list | rofi -dmenu -p "  Clipboard" -config ~/.config/rofi/clipboard.rasi | cut -f1 | xargs -r cliphist decode | wl-copy && wtype -M ctrl -M shift v -m shift -m ctrl]]
  )
)
hl.bind(altMod .. " + C", hl.dsp.exec_cmd("swaync-client -C"))
hl.bind(altMod .. " + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(altMod .. " + W", hl.dsp.exec_cmd("quickshell"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/wallpapers.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/hypr/scripts/live_wallpapers.sh"))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-laptop-display.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("hyprsunset -t 4500"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("hyprsunset -t 6500 || pkill hyprsunset"))
hl.bind(
  mainMod .. " + I",
  hl.dsp.exec_cmd(
    [[rofimoji --selector rofi --selector-args "-config ~/.config/rofi/emoji.rasi" --action type --skin-tone neutral --hidden-descriptions]]
  )
)
hl.bind(
  altMod .. " + I",
  hl.dsp.exec_cmd(
    [[rofimoji --selector rofi --selector-args "-config ~/.config/rofi/emoji.rasi" --action copy --skin-tone neutral --hidden-descriptions]]
  )
)

-- Focus Mapping (Vim Motions)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move Window Mapping (Vim Motions)
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }))

-- Resize Windows (binde equivalent)
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })

-- Mouse Binds for Dragging and Resizing (bindm equivalent)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- hl.gesture({
--     fingers = 4,
--     direction = "horizontal",
--     action = "workspace"
-- })
-- hl.gesture({
--     fingers = 3,
--     direction = "horizontal",
--     action = "workspace"
-- })
-- hl.gesture({
--     fingers = 4,
--     direction = "up",
--     action = "fullscreen"
-- })
-- hl.gesture({
--     fingers = 4,
--     direction = "down",
--     action = "close"
-- })

-- Special Workspaces (Minimize trick via Lua function chaining)
hl.bind(mainMod .. " + M", function()
  hl.dispatch(hl.dsp.window.move({ workspace = "special:magic" }))
  hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
end)
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.workspace.toggle_special("magic"))

-- Workspaces: Switch, Move, Move Silent
for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Relative and Empty Workspaces
hl.bind(mainMod .. " + CTRL + ALT + L", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + ALT + H", hl.dsp.window.move({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + Left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + M", hl.dsp.focus({ workspace = "empty" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Multimedia & Hardware Controls (bindel equivalent: locked & repeating)
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })
hl.bind("XF86ScreenSaver", hl.dsp.exec_cmd("hyprlock"), { locked = true })

hl.bind("CTRL + 1", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("CTRL + 2", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind(
  "CTRL + 3",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)
hl.bind("CTRL + 4", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })
hl.bind("CTRL + 5", hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })

-- Playerctl (bindl equivalent: locked)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind(altMod .. " + P", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshots & Recording (Hyprshot / wf-recorder)
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind(
  mainMod .. " + Print",
  hl.dsp.exec_cmd([[wf-recorder -f ~/Videos/Screenrecordings/recording-$(date +%F_%H-%M-%S).mp4]])
)
hl.bind(
  mainMod .. " + SHIFT + Print",
  hl.dsp.exec_cmd([[wf-recorder -g "$(slurp)" -f ~/Videos/Screenrecordings/recording-$(date +%F_%H-%M-%S).mp4]])
)
hl.bind(mainMod .. " + CTRL + Print", hl.dsp.exec_cmd("pkill -INT wf-recorder"))

-- hl.bind("Menu", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("CTRL + Menu", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots"))
hl.bind("CTRL + SHIFT + Menu", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
