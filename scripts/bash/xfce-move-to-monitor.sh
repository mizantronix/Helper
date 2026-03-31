#!/bin/bash
# Перемещает активное окно на соседний монитор (влево или вправо)
# Использование: move-to-monitor.sh left | right

DIRECTION=$1

# Кэш мониторов — xrandr медленный, не вызываем его каждый раз
# Кэш сбрасывается если изменился список мониторов (по числу подключённых)
CACHE_FILE="/tmp/monitors-cache.txt"
MONITOR_COUNT=$(xrandr | grep -c " connected")

if [ ! -f "$CACHE_FILE" ] || [ "$(head -1 "$CACHE_FILE")" != "$MONITOR_COUNT" ]; then
    echo "$MONITOR_COUNT" > "$CACHE_FILE"
    xrandr | grep " connected" | grep -oP '\d+x\d+\+\d+\+\d+' | \
        awk -F'[x+]' '{print $3":"$1":"$2}' | sort -t: -k1 -n >> "$CACHE_FILE"
fi

MONITORS=$(tail -n +2 "$CACHE_FILE")

# Позиция и размер активного окна + состояние (_NET_WM_STATE) за один вызов
WIN_ID=$(xdotool getactivewindow)
eval $(xdotool getwindowgeometry --shell $WIN_ID)
# Теперь доступны: $X $Y $WIDTH $HEIGHT

# Проверяем максимизацию через xdotool (без отдельного xprop)
WIN_STATE=$(xdotool getwindowgeometry --shell $WIN_ID 2>/dev/null)
WAS_MAXIMIZED=false
if xprop -id $WIN_ID _NET_WM_STATE 2>/dev/null | grep -q "MAXIMIZED"; then
    WAS_MAXIMIZED=true
fi

# Определяем на каком мониторе окно сейчас (по центру окна)
WIN_CENTER_X=$((X + WIDTH / 2))

MONITORS_ARRAY=()
while IFS= read -r line; do
    MONITORS_ARRAY+=("$line")
done <<< "$MONITORS"

TOTAL=${#MONITORS_ARRAY[@]}
CURRENT_IDX=0

for i in "${!MONITORS_ARRAY[@]}"; do
    MON_X=$(echo "${MONITORS_ARRAY[$i]}" | cut -d: -f1)
    MON_W=$(echo "${MONITORS_ARRAY[$i]}" | cut -d: -f2)
    MON_RIGHT=$((MON_X + MON_W))
    if [ "$WIN_CENTER_X" -ge "$MON_X" ] && [ "$WIN_CENTER_X" -lt "$MON_RIGHT" ]; then
        CURRENT_IDX=$i
        break
    fi
done

# Вычисляем целевой монитор
if [ "$DIRECTION" = "left" ]; then
    TARGET_IDX=$((CURRENT_IDX - 1))
else
    TARGET_IDX=$((CURRENT_IDX + 1))
fi

# Не выходим за границы
if [ "$TARGET_IDX" -lt 0 ] || [ "$TARGET_IDX" -ge "$TOTAL" ]; then
    exit 0
fi

# Считаем позицию на целевом мониторе
CURR_MON_X=$(echo "${MONITORS_ARRAY[$CURRENT_IDX]}" | cut -d: -f1)
TARGET_MON_X=$(echo "${MONITORS_ARRAY[$TARGET_IDX]}" | cut -d: -f1)
NEW_X=$((TARGET_MON_X + (X - CURR_MON_X)))

# Убираем максимизацию, двигаем, восстанавливаем
wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz
xdotool windowmove $WIN_ID $NEW_X $Y

if [ "$WAS_MAXIMIZED" = true ]; then
    wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
fi
