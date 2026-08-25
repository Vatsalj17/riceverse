require("variables")
require("binds")

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
  -- mirror = "DP-1",
})

hl.on("hyprland.start", function()
  local daemons = {
    "swaync",
    "wl-paste --watch cliphist store",
    "awww-daemon",
    "hypridle",
    "XDG_SESSION_TYPE=x11 kdeconnectd",
    "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
    "systemctl --user set-environment GTK_THEME=catppuccin-mocha-mauve-standard+default:dark",
    "xhost +SI:localuser:root",
  }

  for _, cmd in ipairs(daemons) do
    hl.exec_cmd(cmd)
  end

  -- Scripts
  hl.exec_cmd("~/.config/hypr/scripts/system-monitor.sh &")
  hl.exec_cmd("~/.config/hypr/scripts/wallpaper-rotator.sh &")
  hl.exec_cmd("~/.config/hypr/scripts/update_wallpaper_cache.sh")

  -- Delayed launches
  hl.timer(function()
    hl.exec_cmd("waybar")
  end, { timeout = 1000, type = "oneshot" })

  hl.timer(function()
    hl.exec_cmd("firefox", { workspace = "10" })
  end, { timeout = 1000, type = "oneshot" })

  hl.timer(function()
    hl.exec_cmd("kitty", { workspace = "9" })
  end, { timeout = 1000, type = "oneshot" })
end)

-- Window Rules
local opacities = {
  ["google-chrome"] = "0.92 override",
  ["org.qutebrowser.qutebrowser"] = "0.80 override",
  ["spotify"] = "0.70 override",
  ["wasistlos"] = "0.92 override",
  ["kitty"] = "0.70 override",
  ["foot"] = "0.70 override",
  ["code"] = "0.80 override",
  ["zen"] = "0.90 override",
  ["brave-browser"] = "0.92 override",
  ["brave-kinpkbniadkppecjaginbegiljofpcfc-Default"] = "0.95 override",
  ["brave-cinhimbnkkaeohfgghhklpknlkffjgod-Default"] = "0.80 override",
  ["pcmanfm-qt"] = "0.70 override",
  ["wihotspot"] = "0.88 override",
  ["org.kde.kdeconnect.app|org.kde.kdeconnect.daemon"] = "0.88 override",
  ["com.github.wwmm.easyeffects"] = "0.88 override",
  ["zathura"] = "0.88 override",
}

for class_name, opacity_val in pairs(opacities) do
  hl.window_rule({
    name = "opacity-" .. class_name,
    match = { class = class_name },
    opacity = opacity_val,
  })
end

-- spcial opacity of YouTube
hl.window_rule({ name = "yt opacity", match = { title = ".*YouTube.*" }, opacity = "1.00 override" })

-- Floating Rules
local floating_classes = { "^Tk$", "^Gitk$", "^qemu$", "^Matplotlib$", "^swayimg$" }
for _, class_name in ipairs(floating_classes) do
  hl.window_rule({
    name = "float-" .. class_name,
    match = { class = class_name },
    float = true,
    center = true,
  })
end

hl.window_rule({ match = { title = "Picture-in-Picture" }, float = true })
