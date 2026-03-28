#!/bin/bash
# Conky setup: two-panel desktop widget with Lua Cairo cards
# Requires: nvidia GPU, network interface enp5s0
# Tested on: Linux Mint 22.3 XFCE

set -e

IFACE="${1:-enp5s0}"

echo ">>> Installing packages..."
sudo apt install -y conky-all fonts-jetbrains-mono vnstat

echo ">>> Creating directories..."
mkdir -p ~/.config/conky
mkdir -p ~/.config/autostart

echo ">>> Writing right panel config..."
cat > ~/.config/conky/right.conf << 'EOF'
conky.config = {
    alignment = 'top_right',
    gap_x = 20,
    gap_y = 40,

    minimum_width = 230,
    maximum_width = 230,

    own_window = true,
    own_window_type = 'desktop',
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    own_window_colour = '000000',

    border_inner_margin = 0,
    border_outer_margin = 0,
    border_width = 0,

    font = 'JetBrains Mono:size=9',
    use_xft = true,
    xftalpha = 1,

    default_color = 'c0caf5',
    color1 = '7aa2f7',
    color2 = 'a9b1d6',
    color3 = '9ece6a',

    update_interval = 2,
    double_buffer = true,
    no_buffers = true,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,

    lua_load = '~/.config/conky/draw_right.lua',
    lua_draw_hook_pre = 'draw_right',
}

conky.text = [[
${voffset 8}${color1}${font JetBrains Mono:size=22:bold}  ${time %H:%M}${font}
  ${color2}${time %A, %d %B %Y}
${voffset 16}  ${color1}SYSTEM
  ${color2}Uptime:  ${color3}${uptime}
  ${color2}Kernel:  ${color3}${kernel}
${voffset 16}  ${color1}CPU  ${color2}${freq_g} GHz  ${color3}${cpu cpu0}%
  ${cpubar 6,206}
  ${color2}Temp:  ${color3}${hwmon 0 temp 1}°C
  ${color2}Load:  ${color3}${loadavg 1} ${loadavg 2} ${loadavg 3}
${voffset 16}  ${color1}MEMORY
  ${color2}RAM:   ${color3}${mem} / ${memmax}
  ${membar 6,206}
  ${color2}Swap:  ${color3}${swap} / ${swapmax}
${voffset 16}  ${color1}DISK
  ${color2}Root:  ${color3}${fs_used /} / ${fs_size /}
  ${fs_bar 6,206 /}
${voffset 16}  ${color1}NETWORK
  ${color2}Down:  ${color3}${downspeed IFACE}  ${color2}Up: ${color3}${upspeed IFACE}
  ${color2}IP:    ${color3}${addr IFACE}
  ${color2}Total: ${color3}${execi 10 vnstat -i IFACE --oneline | awk -F';' '{print $10 " rx / " $11 " tx"}'}
${voffset 10}
]]
EOF
sed -i "s/IFACE/$IFACE/g" ~/.config/conky/right.conf

echo ">>> Writing left panel config..."
cat > ~/.config/conky/left.conf << 'EOF'
conky.config = {
    alignment = 'top_right',
    gap_x = 258,
    gap_y = 40,

    minimum_width = 190,
    maximum_width = 190,

    own_window = true,
    own_window_type = 'desktop',
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    own_window_colour = '000000',

    border_inner_margin = 0,
    border_outer_margin = 0,
    border_width = 0,

    font = 'JetBrains Mono:size=9',
    use_xft = true,
    xftalpha = 1,

    default_color = 'c0caf5',
    color1 = '7aa2f7',
    color2 = 'a9b1d6',
    color3 = '9ece6a',

    update_interval = 2,
    double_buffer = true,
    no_buffers = true,
    draw_shades = false,
    draw_outline = false,
    draw_borders = false,

    lua_load = '~/.config/conky/draw_left.lua',
    lua_draw_hook_pre = 'draw_left',
}

conky.text = [[
${voffset 8}${offset 8}${color1}GPU  ${color3}${execi 3 nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits}%
${offset 8}${color2}Temp:  ${color3}${execi 3 nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader}°C
${offset 8}${color2}VRAM:  ${color3}${execi 3 nvidia-smi --query-gpu=memory.used --format=csv,noheader} / ${execi 60 nvidia-smi --query-gpu=memory.total --format=csv,noheader}
${voffset 14}${offset 8}${color1}TOP CPU
${offset 8}${color2}${top name 1}  ${color3}${top cpu 1}%
${offset 8}${color2}${top name 2}  ${color3}${top cpu 2}%
${offset 8}${color2}${top name 3}  ${color3}${top cpu 3}%
${offset 8}${color2}${top name 4}  ${color3}${top cpu 4}%
${voffset 14}${offset 8}${color1}TOP MEM
${offset 8}${color2}${top_mem name 1}  ${color3}${top_mem mem_res 1}
${offset 8}${color2}${top_mem name 2}  ${color3}${top_mem mem_res 2}
${offset 8}${color2}${top_mem name 3}  ${color3}${top_mem mem_res 3}
${offset 8}${color2}${top_mem name 4}  ${color3}${top_mem mem_res 4}
]]
EOF

echo ">>> Writing Lua card scripts..."
cat > ~/.config/conky/draw_right.lua << 'EOF'
require 'cairo'

function draw_rounded_rect(cr, x, y, w, h, r, col_r, col_g, col_b, alpha)
    cairo_set_source_rgba(cr, col_r, col_g, col_b, alpha)
    cairo_new_path(cr)
    cairo_move_to(cr, x + r, y)
    cairo_line_to(cr, x + w - r, y)
    cairo_arc(cr, x + w - r, y + r, r, -math.pi/2, 0)
    cairo_line_to(cr, x + w, y + h - r)
    cairo_arc(cr, x + w - r, y + h - r, r, 0, math.pi/2)
    cairo_line_to(cr, x + r, y + h)
    cairo_arc(cr, x + r, y + h - r, r, math.pi/2, math.pi)
    cairo_line_to(cr, x, y + r)
    cairo_arc(cr, x + r, y + r, r, math.pi, 3*math.pi/2)
    cairo_close_path(cr)
    cairo_fill(cr)
end

function conky_draw_right()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(
        conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    local w = conky_window.width
    local r, a = 10, 0.65
    local br, bg, bb = 0.10, 0.10, 0.18

    local cards = {
        {0,   0, w,  66},  -- Время / Дата
        {0,  72, w,  58},  -- System
        {0, 136, w,  74},  -- CPU
        {0, 216, w,  82},  -- Memory
        {0, 304, w,  62},  -- Disk
        {0, 372, w,  80},  -- Network
    }

    for _, c in ipairs(cards) do
        draw_rounded_rect(cr, c[1], c[2], c[3], c[4], r, br, bg, bb, a)
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
EOF

cat > ~/.config/conky/draw_left.lua << 'EOF'
require 'cairo'

function draw_rounded_rect(cr, x, y, w, h, r, col_r, col_g, col_b, alpha)
    cairo_set_source_rgba(cr, col_r, col_g, col_b, alpha)
    cairo_new_path(cr)
    cairo_move_to(cr, x + r, y)
    cairo_line_to(cr, x + w - r, y)
    cairo_arc(cr, x + w - r, y + r, r, -math.pi/2, 0)
    cairo_line_to(cr, x + w, y + h - r)
    cairo_arc(cr, x + w - r, y + h - r, r, 0, math.pi/2)
    cairo_line_to(cr, x + r, y + h)
    cairo_arc(cr, x + r, y + h - r, r, math.pi/2, math.pi)
    cairo_line_to(cr, x, y + r)
    cairo_arc(cr, x + r, y + r, r, math.pi, 3*math.pi/2)
    cairo_close_path(cr)
    cairo_fill(cr)
end

function conky_draw_left()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(
        conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    local w = conky_window.width
    local r, a = 10, 0.65
    local br, bg, bb = 0.10, 0.10, 0.18

    local cards = {
        {0,   0, w,  62},  -- GPU
        {0,  68, w,  92},  -- Top CPU
        {0, 166, w,  92},  -- Top MEM
    }

    for _, c in ipairs(cards) do
        draw_rounded_rect(cr, c[1], c[2], c[3], c[4], r, br, bg, bb, a)
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
EOF

echo ">>> Writing autostart entries..."
cat > ~/.config/autostart/conky-right.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Conky Right
Exec=bash -c "sleep 5 && conky -c ~/.config/conky/right.conf"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

cat > ~/.config/autostart/conky-left.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Conky Left
Exec=bash -c "sleep 5 && conky -c ~/.config/conky/left.conf"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

echo ">>> Done. Starting conky..."
killall conky 2>/dev/null || true
sleep 1
conky -c ~/.config/conky/right.conf &
conky -c ~/.config/conky/left.conf &

echo ">>> Conky is running. Network interface: $IFACE"
echo "    To use a different interface: $0 <interface>"
