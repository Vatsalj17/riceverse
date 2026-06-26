local mocha = require("mocha")

-- Environment Variables
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GTK_THEME", "catppuccin-mocha-mauve-standard+default:dark")
hl.env("SSH_AUTH_SOCK", "/run/user/1000/keyring/ssh")

hl.config({
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    force_no_accel = false,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
      tap_to_click = true,
    },
  },

  general = {
    gaps_in = 2,
    gaps_out = 5,
    border_size = 2,
    col = {
      active_border = { colors = { mocha.mauve, mocha.flamingo }, angle = 45 },
      inactive_border = mocha.overlay0,
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
    snap = {
      enabled = true,
      window_gap = 5,
      monitor_gap = 5,
    },
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,
    fullscreen_opacity = 1.0,
    dim_inactive = true,
    dim_strength = 0.15,
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      sharp = false,
      color = mocha.base,
      offset = { 3, 3 },
      scale = 1,
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 3,
      vibrancy = 0.1696,
    },
  },

  gestures = {
    -- How far you have to swipe (in pixels) to trigger a full workspace change
    workspace_swipe_distance = 200,
    -- If you lift your fingers before this ratio (0.5 = 50%), the swipe cancels and snaps back
    workspace_swipe_cancel_ratio = 0.3,
    -- Swiping past your last workspace automatically creates a new one
    workspace_swipe_create_new = false,
    -- Locks the swipe strictly to one axis so you don't accidentally trigger vertical binds
    workspace_swipe_direction_lock = true,
    workspace_swipe_direction_lock_threshold = 10,
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  xwayland = {
    force_zero_scaling = true,
  },

  cursor = {
    inactive_timeout = 2,
    hide_on_key_press = true,
    no_hardware_cursors = true,
  },

  group = {
    col = {
      -- Utilizing the mocha module we required at the top
      border_active = { colors = { mocha.mauve, mocha.flamingo }, angle = 45 },
      border_inactive = mocha.overlay0,
    },
    groupbar = {
      enabled = true,
      font_family = "JetBrainsMono Nerd Font",
      font_size = 10,
      height = 15,
      render_titles = true,
      text_color = mocha.text,
      col = {
        -- Hardcoding the raw hex to achieve your specific 'cc' and '66' alpha overrides
        -- cba6f7 is Mocha Mauve, 45475a is Mocha Surface1
        active = { colors = { "rgba(cba6f7cc)" }, angle = 90 },
        inactive = "rgba(45475a66)",
      },
    },
  },
})

-- Animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutQuint", style = "slide" })
