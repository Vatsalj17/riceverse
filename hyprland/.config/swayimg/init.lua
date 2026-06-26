-- ~/.config/swayimg/init.lua
-- swayimg 5.2 — Hyprland / Catppuccin Mocha
-- Key names: xkbcli interactive-wayland

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------
swayimg.set_mode("viewer")
swayimg.enable_antialiasing(true)
swayimg.enable_decoration(false)       -- Hyprland handles borders
swayimg.enable_overlay(true)           -- float over focused window
swayimg.enable_exif_orientation(true)
swayimg.set_dnd_button("MouseLeft")

--------------------------------------------------------------------------------
-- Image list
--------------------------------------------------------------------------------
swayimg.imagelist.set_order("alpha")
swayimg.imagelist.enable_reverse(false)
swayimg.imagelist.enable_recursive(false)
swayimg.imagelist.enable_adjacent(true)  -- load whole dir when opening one file
swayimg.imagelist.enable_fsmon(true)

--------------------------------------------------------------------------------
-- Text / overlay — Catppuccin Mocha
--------------------------------------------------------------------------------
swayimg.text.set_font("monospace")
swayimg.text.set_size(13)
swayimg.text.set_spacing(2)
swayimg.text.set_padding(10)
swayimg.text.set_foreground(0xffcdd6f4)  -- Mocha text
swayimg.text.set_background(0x00000000)
swayimg.text.set_shadow(0xcc11111b)      -- Mocha crust
swayimg.text.set_timeout(4)
swayimg.text.set_status_timeout(3)

--------------------------------------------------------------------------------
-- Viewer
--------------------------------------------------------------------------------
swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.set_default_position("center")
swayimg.viewer.set_drag_button("MouseLeft")
swayimg.viewer.set_window_background(0x00000000)
swayimg.viewer.set_image_chessboard(16, 0xff313244, 0xff45475a)  -- Mocha surface
swayimg.viewer.enable_centering(true)
swayimg.viewer.enable_loop(true)
swayimg.viewer.limit_preload(2)
swayimg.viewer.limit_history(3)
swayimg.viewer.set_mark_color(0xffcba6f7)   -- Mocha mauve
swayimg.viewer.set_pinch_factor(1.0)

swayimg.viewer.set_text("topleft", {
    "File:   {name}",
    "Format: {format}",
    "Size:   {sizehr}",
    "Pixels: {frame.width}x{frame.height}",
    "EXIF:   {meta.Exif.Photo.DateTimeOriginal}",
})
swayimg.viewer.set_text("topright", {
    "{list.index}/{list.total}",
    "{frame.index}/{frame.total} frames",
})
swayimg.viewer.set_text("bottomleft", {
    "Scale: {scale}",
})
swayimg.viewer.set_text("bottomright", {})

--------------------------------------------------------------------------------
-- Slideshow
--------------------------------------------------------------------------------
swayimg.slideshow.set_timeout(5)
swayimg.slideshow.set_default_scale("fit")
swayimg.slideshow.set_window_background("auto")
swayimg.slideshow.limit_history(0)
swayimg.slideshow.set_text("topleft", { "{name}" })
swayimg.slideshow.set_text("topright", { "{list.index}/{list.total}" })

--------------------------------------------------------------------------------
-- Gallery — Catppuccin Mocha
--------------------------------------------------------------------------------
swayimg.gallery.set_aspect("fill")
swayimg.gallery.set_thumb_size(200)
swayimg.gallery.set_padding_size(4)
swayimg.gallery.set_border_size(3)
swayimg.gallery.set_border_color(0xffcba6f7)       -- Mocha mauve
swayimg.gallery.set_selected_scale(1.1)
swayimg.gallery.set_selected_color(0xff313244)     -- Mocha surface0
swayimg.gallery.set_unselected_color(0xff181825)   -- Mocha mantle
swayimg.gallery.set_window_color(0xff1e1e2e)       -- Mocha base
swayimg.gallery.set_pinch_factor(100.0)
swayimg.gallery.limit_cache(150)
swayimg.gallery.enable_preload(true)
swayimg.gallery.enable_pstore(true)
swayimg.gallery.set_text("topleft", {})
swayimg.gallery.set_text("topright", {})
swayimg.gallery.set_text("bottomleft", {})
swayimg.gallery.set_text("bottomright", { "{name}" })

--------------------------------------------------------------------------------
-- Viewer keybindings
--------------------------------------------------------------------------------

-- Quit
swayimg.viewer.on_key("q",      function() swayimg.exit() end)
swayimg.viewer.on_key("Escape", function() swayimg.exit() end)

-- Next / prev image
swayimg.viewer.on_key("l",         function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("h",         function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("j",         function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("k",         function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("Space",     function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("BackSpace", function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("Right",     function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("Left",      function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("Next",      function() swayimg.viewer.switch_image("next") end)  -- PgDn
swayimg.viewer.on_key("Prior",     function() swayimg.viewer.switch_image("prev") end)  -- PgUp

-- First / last
swayimg.viewer.on_key("g",    function() swayimg.viewer.switch_image("first") end)
swayimg.viewer.on_key("G",    function() swayimg.viewer.switch_image("last") end)
swayimg.viewer.on_key("Home", function() swayimg.viewer.switch_image("first") end)
swayimg.viewer.on_key("End",  function() swayimg.viewer.switch_image("last") end)

-- Directory jumps
swayimg.viewer.on_key("Shift-l", function() swayimg.viewer.switch_image("next_dir") end)
swayimg.viewer.on_key("Shift-h", function() swayimg.viewer.switch_image("prev_dir") end)

-- Random
swayimg.viewer.on_key("Shift-r", function() swayimg.viewer.switch_image("random") end)

-- Frames / animation
swayimg.viewer.on_key("period", function() swayimg.viewer.next_frame() end)
swayimg.viewer.on_key("comma",  function() swayimg.viewer.prev_frame() end)
swayimg.viewer.on_key("a",      function() swayimg.viewer.set_animation() end)

-- Zoom
local function zoom_by(factor)
    local s = swayimg.viewer.get_scale()
    swayimg.viewer.set_abs_scale(math.max(0.01, s * factor))
end
swayimg.viewer.on_key("equal", function() zoom_by(1.1) end)
swayimg.viewer.on_key("plus",  function() zoom_by(1.1) end)
swayimg.viewer.on_key("minus", function() zoom_by(0.9) end)
swayimg.viewer.on_key("0", function() swayimg.viewer.set_fix_scale("real") end)
swayimg.viewer.on_key("w", function() swayimg.viewer.set_fix_scale("width") end)
swayimg.viewer.on_key("W", function() swayimg.viewer.set_fix_scale("height") end)
swayimg.viewer.on_key("z", function() swayimg.viewer.set_fix_scale("fit") end)
swayimg.viewer.on_key("Z", function() swayimg.viewer.set_fix_scale("fill") end)
swayimg.viewer.on_key("x", function() swayimg.viewer.set_fix_scale("optimal") end)

-- Pan (Ctrl+hjkl) — 5% of window per press
swayimg.viewer.on_key("Ctrl-l", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x - math.floor(wnd.width * 0.05), pos.y)
end)
swayimg.viewer.on_key("Ctrl-h", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x + math.floor(wnd.width * 0.05), pos.y)
end)
swayimg.viewer.on_key("Ctrl-j", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, pos.y - math.floor(wnd.height * 0.05))
end)
swayimg.viewer.on_key("Ctrl-k", function()
    local wnd = swayimg.get_window_size()
    local pos = swayimg.viewer.get_position()
    swayimg.viewer.set_abs_position(pos.x, pos.y + math.floor(wnd.height * 0.05))
end)

-- Transform
swayimg.viewer.on_key("bracketleft",  function() swayimg.viewer.rotate(270) end)
swayimg.viewer.on_key("bracketright", function() swayimg.viewer.rotate(90) end)
swayimg.viewer.on_key("m", function() swayimg.viewer.flip_vertical() end)
swayimg.viewer.on_key("M", function() swayimg.viewer.flip_horizontal() end)

-- Toggles
swayimg.viewer.on_key("f", function() swayimg.set_fullscreen() end)
swayimg.viewer.on_key("i", function() if swayimg.text.visible() then swayimg.text.hide() else swayimg.text.show() end end)
swayimg.viewer.on_key("r", function() swayimg.viewer.reload() end)
-- swayimg.viewer.on_key("F1", function() swayimg.help() end)

-- Mode switch
swayimg.viewer.on_key("Return", function() swayimg.set_mode("gallery") end)
swayimg.viewer.on_key("s",      function() swayimg.set_mode("slideshow") end)

-- Yank path
swayimg.viewer.on_key("y", function()
    local img = swayimg.viewer.get_image()
    print(img.path)
end)

-- Mouse scroll: zoom centered on cursor
swayimg.viewer.on_mouse("ScrollUp", function()
    local pos = swayimg.get_mouse_pos()
    local s = swayimg.viewer.get_scale()
    swayimg.viewer.set_abs_scale(s * 1.05, pos.x, pos.y)
end)
swayimg.viewer.on_mouse("ScrollDown", function()
    local pos = swayimg.get_mouse_pos()
    local s = swayimg.viewer.get_scale()
    swayimg.viewer.set_abs_scale(math.max(0.01, s * 0.95), pos.x, pos.y)
end)
swayimg.viewer.on_mouse("Ctrl-ScrollUp", function()
    local pos = swayimg.get_mouse_pos()
    local s = swayimg.viewer.get_scale()
    swayimg.viewer.set_abs_scale(s * 1.1, pos.x, pos.y)
end)
swayimg.viewer.on_mouse("Ctrl-ScrollDown", function()
    local pos = swayimg.get_mouse_pos()
    local s = swayimg.viewer.get_scale()
    swayimg.viewer.set_abs_scale(math.max(0.01, s * 0.9), pos.x, pos.y)
end)
swayimg.viewer.on_mouse("Shift-ScrollUp",   function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_mouse("Shift-ScrollDown", function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_mouse("Alt-ScrollUp",     function() swayimg.viewer.prev_frame() end)
swayimg.viewer.on_mouse("Alt-ScrollDown",   function() swayimg.viewer.next_frame() end)

--------------------------------------------------------------------------------
-- Slideshow keybindings
--------------------------------------------------------------------------------
swayimg.slideshow.on_key("q",      function() swayimg.exit() end)
swayimg.slideshow.on_key("Escape", function() swayimg.exit() end)
swayimg.slideshow.on_key("Space",  function() swayimg.set_mode("viewer") end)
swayimg.slideshow.on_key("period", function() swayimg.slideshow.switch_image("next") end)
swayimg.slideshow.on_key("comma",  function() swayimg.slideshow.switch_image("prev") end)
swayimg.slideshow.on_key("g",      function() swayimg.slideshow.switch_image("first") end)
swayimg.slideshow.on_key("G",      function() swayimg.slideshow.switch_image("last") end)
swayimg.slideshow.on_key("f",      function() swayimg.set_fullscreen() end)
swayimg.slideshow.on_key("i",      function() if swayimg.text.visible() then swayimg.text.hide() else swayimg.text.show() end end)
-- swayimg.slideshow.on_key("r",      function() swayimg.slideshow.reload() end)
swayimg.slideshow.on_key("Return", function() swayimg.set_mode("viewer") end)

--------------------------------------------------------------------------------
-- Gallery keybindings
--------------------------------------------------------------------------------
swayimg.gallery.on_key("q",      function() swayimg.exit() end)
swayimg.gallery.on_key("Escape", function() swayimg.exit() end)

swayimg.gallery.on_key("h",     function() swayimg.gallery.switch_image("left") end)
swayimg.gallery.on_key("l",     function() swayimg.gallery.switch_image("right") end)
swayimg.gallery.on_key("k",     function() swayimg.gallery.switch_image("up") end)
swayimg.gallery.on_key("j",     function() swayimg.gallery.switch_image("down") end)
swayimg.gallery.on_key("Left",  function() swayimg.gallery.switch_image("left") end)
swayimg.gallery.on_key("Right", function() swayimg.gallery.switch_image("right") end)
swayimg.gallery.on_key("Up",    function() swayimg.gallery.switch_image("up") end)
swayimg.gallery.on_key("Down",  function() swayimg.gallery.switch_image("down") end)
swayimg.gallery.on_key("J",     function() swayimg.gallery.switch_image("pgdown") end)
swayimg.gallery.on_key("K",     function() swayimg.gallery.switch_image("pgup") end)
swayimg.gallery.on_key("Next",  function() swayimg.gallery.switch_image("pgdown") end)
swayimg.gallery.on_key("Prior", function() swayimg.gallery.switch_image("pgup") end)
swayimg.gallery.on_key("g",     function() swayimg.gallery.switch_image("first") end)
swayimg.gallery.on_key("G",     function() swayimg.gallery.switch_image("last") end)
swayimg.gallery.on_key("Home",  function() swayimg.gallery.switch_image("first") end)
swayimg.gallery.on_key("End",   function() swayimg.gallery.switch_image("last") end)

swayimg.gallery.on_key("Return", function() swayimg.set_mode("viewer") end)
swayimg.gallery.on_key("f",  function() swayimg.set_fullscreen() end)
swayimg.gallery.on_key("i",  function() if swayimg.text.visible() then swayimg.text.hide() else swayimg.text.show() end end)
-- swayimg.gallery.on_key("r",  function() swayimg.gallery.reload() end)
-- swayimg.gallery.on_key("F1", function() swayimg.help() end)

swayimg.gallery.on_key("y", function()
    local img = swayimg.gallery.get_image()
    print(img.path)
end)

swayimg.gallery.on_mouse("ScrollUp",    function() swayimg.gallery.switch_image("up") end)
swayimg.gallery.on_mouse("ScrollDown",  function() swayimg.gallery.switch_image("down") end)
swayimg.gallery.on_mouse("ScrollLeft",  function() swayimg.gallery.switch_image("left") end)
swayimg.gallery.on_mouse("ScrollRight", function() swayimg.gallery.switch_image("right") end)

--------------------------------------------------------------------------------
-- Hooks
--------------------------------------------------------------------------------
-- Re-fit on resize (useful when Hyprland resizes the float)
swayimg.on_window_resize(function()
    swayimg.viewer.set_fix_scale("optimal")
end)

-- Window title tracks current file in gallery
swayimg.gallery.on_image_change(function()
    local img = swayimg.gallery.get_image()
    swayimg.set_title("swayimg: " .. img.path)
end)
