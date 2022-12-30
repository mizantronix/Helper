Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install vscode git gitextensions kdiff3 nugetpackageexplorer notepadplusplus fiddler far wsl putty nodejs tightvnc dotnet-sdk yandexdisk steam-client telegram.install winscp -y
