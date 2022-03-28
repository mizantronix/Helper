Param(
    [switch]
    $additionalSoft = $false
)

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

#vscode
choco install vscode -y

#git stuff 
choco install git -y
choco install gitextensions -y
choco install kdiff3 -y

if ($additionalSoft)
{
    choco install notepadplusplus -y
    choco install steam-client -y
    choco install telegram.install -y
}
