Param(
    [switch]
    $additionalSoft = $false
)

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install vscode -y
choco install git -y
choco install gitextensions -y
choco install kdiff3 -y
choco install nugetpackageexplorer -y
choco install notepadplusplus -y
choco install fiddler -y
choco install far -y
choco install wsl -y
choco install putty -y
choco install nodejs -y
choco install tightvnc -y
choco install dotnet-sdk -y

if ($additionalSoft)
{
    choco install steam-client -y
    choco install telegram.install -y
}
