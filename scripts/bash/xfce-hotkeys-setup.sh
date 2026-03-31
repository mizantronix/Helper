#!/bin/bash
# =============================================================================
# xfce-hotkeys-setup.sh
# Настройка горячих клавиш в стиле Windows для XFCE
#
# Результат:
#   - Super (одиночно)  → открывает Whisker Menu ("Пуск")
#   - Super+Up          → развернуть окно на весь экран (maximize)
#   - Super+Down        → вернуть окно к предыдущему размеру (unmaximize)
#
# =============================================================================
# ПОЧЕМУ ЭТО ТАК УСТРОЕНО (грабли которые были пройдены)
# =============================================================================
#
# Проблема 1: XFCE эксклюзивно захватывает Super
#   По умолчанию Whisker Menu висит на клавише Super. XFCE реализует это через
#   XGrabKey с эксклюзивным захватом — это значит что событие нажатия Super
#   целиком съедается XFCE и до других приложений (xbindkeys, xev, xdotool)
#   не доходит ВООБЩЕ. Нажимаешь Super+Up — xev молчит, xbindkeys молчит.
#
#   Симптом: xev не видит ни Super, ни Super+Up.
#   Причина: XGrabKey в XFCE на Super_L со значением "/bin/true" или
#            "xfce4-popup-whiskermenu" — неважно что там запускается,
#            важно что граб эксклюзивный.
#
# Проблема 2: xdotool windowstate не существует
#   Первая попытка была через xbindkeys + xdotool windowstate --add MAXIMIZED.
#   Команда windowstate не существует в этой версии xdotool.
#   Решение: wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz
#
# Решение (три компонента):
#
#   1. Убрать Super_L из shortcuts XFCE
#      Удаляем XGrabKey XFCE на Super — теперь Super виден всем.
#
#   2. xcape: Super_L → F13 (одиночное нажатие)
#      xcape слушает через XRecord (без граба, не мешает другим).
#      Если Super нажали и отпустили БЕЗ другой клавиши — посылает F13.
#      Если Super+что-то — не вмешивается, комбо проходит как есть.
#      F13 настраивается как шорткат на Whisker Menu.
#      Нюанс: F13 нет в стандартной раскладке, надо назначить через xmodmap.
#
#   3. xbindkeys: Super+Up / Super+Down → wmctrl
#      Теперь когда XFCE не хватает Super — xbindkeys может спокойно
#      зарегистрировать комбинации Super+Up и Super+Down.
#
# Ручные шаги после запуска скрипта:
#   Убедиться что в свойствах Whisker Menu стоит F13 (не Super):
#   ПКМ по кнопке Пуск → Properties → Keyboard shortcut → F13
#   (если стоит Super — убрать и поставить F13)
#
# Зависимости:
#   sudo apt install xbindkeys xdotool xcape wmctrl
#
# Использование:
#   bash xfce-hotkeys-setup.sh
# =============================================================================

set -e

echo "=== Настройка горячих клавиш XFCE ==="

# --- 1. Зависимости ---
echo "[*] Устанавливаю зависимости..."
sudo apt install -y xbindkeys xdotool xcape wmctrl
echo "[+] Зависимости установлены"

# --- 2. Убираем эксклюзивный граб XFCE на Super_L ---
# Это ключевой шаг. Пока этот биндинг есть — Super и все Super+* комбинации
# невидимы для xbindkeys, xev и всего остального.
echo "[*] Убираю эксклюзивный граб XFCE на Super_L..."
xfconf-query -c xfce4-keyboard-shortcuts -p '/commands/custom/Super_L' --reset 2>/dev/null || true
echo "[+] Граб снят"

# --- 3. Конфиг xbindkeys ---
XBINDKEYS_CONF="$HOME/.xbindkeysrc"

if [ -f "$XBINDKEYS_CONF" ]; then
    cp "$XBINDKEYS_CONF" "${XBINDKEYS_CONF}.bak"
    echo "[+] Старый конфиг xbindkeys → ${XBINDKEYS_CONF}.bak"
fi

cat > "$XBINDKEYS_CONF" << 'EOF'
# xbindkeys config — управление окнами в стиле Windows
# Работает только если в XFCE нет эксклюзивного граба на Super_L

# Super+Up → maximize
"wmctrl -r :ACTIVE: -b add,maximized_vert,maximized_horz"
  m:0x40 + c:111

# Super+Down → unmaximize (restore)
"wmctrl -r :ACTIVE: -b remove,maximized_vert,maximized_horz"
  m:0x40 + c:116
EOF

echo "[+] Конфиг xbindkeys записан"

# --- 4. F13 на keycode 97 (в стандартной раскладке не назначен) ---
xmodmap -e "keycode 97 = F13"
echo "[+] F13 назначен на keycode 97"

# --- 5. Автозапуск: xmodmap + xbindkeys + xcape ---
AUTOSTART_DIR="$HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

# xmodmap и xcape — в одном скрипте, порядок важен:
# xcape ищет F13 по keysym, если xmodmap не отработал первым — xcape падает.
# Поэтому не два отдельных .desktop, а один скрипт-обёртка.
SETUP_SCRIPT="$AUTOSTART_DIR/super-key-setup.sh"

cat > "$SETUP_SCRIPT" << 'EOF'
#!/bin/bash
# Запускается при старте сессии XFCE
# Порядок важен: сначала xmodmap (регистрирует F13), потом xcape

sleep 1  # ждём пока XFCE полностью инициализируется

xmodmap -e "keycode 97 = F13"
xcape -e 'Super_L=F13'
EOF
chmod +x "$SETUP_SCRIPT"

cat > "$AUTOSTART_DIR/super-key-setup.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Super key setup
Exec=$SETUP_SCRIPT
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

cat > "$AUTOSTART_DIR/xbindkeys.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=xbindkeys
Exec=xbindkeys
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

# Убираем старые раздельные файлы если остались
rm -f "$AUTOSTART_DIR/xmodmap-f13.desktop"
rm -f "$AUTOSTART_DIR/xcape.desktop"

echo "[+] Автозапуск добавлен (super-key-setup.sh, xbindkeys)"

# --- 6. Запуск в текущей сессии ---
pkill xbindkeys 2>/dev/null || true
pkill xcape 2>/dev/null || true
sleep 0.3

xbindkeys
xcape -e 'Super_L=F13'

echo "[+] xbindkeys и xcape запущены"
echo ""
echo "=== Готово ==="
echo "Проверь что в свойствах Whisker Menu стоит F13 (не Super):"
echo "  ПКМ по кнопке Пуск → Properties → Keyboard shortcut"
echo ""
echo "Должно работать:"
echo "  Super (одиночно)  → открывает меню"
echo "  Super+Up          → разворачивает окно"
echo "  Super+Down        → возвращает размер"
