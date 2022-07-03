# https://betanews.com/2022/01/13/kb5009543-and-kb5009566-updates-are-breaking-vpn-connections-in-windows/

if ((Get-WmiObject -class Win32_OperatingSystem).Caption -match 'Windows 11') {
  if (get-hotfix -id KB5009566 -ErrorAction SilentlyContinue) {
    write-host 'Removing crashing update..' -NoNewLine -ForegroundColor Yellow
    wusa /uninstall /kb:5009566
  } else { write-host 'You do not have crashing update, congrats!' -ForegroundColor Green }
} else {
  if (get-hotfix -id KB5009543 -ErrorAction SilentlyContinue) {
    write-host 'Removing crashing update..' -NoNewLine -ForegroundColor Yellow
    wusa /uninstall /kb:5009543
  } else { write-host 'You do not have crashing update, congrats!' -ForegroundColor Green }
}
