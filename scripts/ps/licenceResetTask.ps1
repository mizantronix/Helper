$trigger = New-JobTrigger -DaysInterval 30 -Daily -At 10:00

# Resharper

Register-ScheduledJob -Name "Clear resharper licence" -Trigger $trigger -ScriptBlock {
  if (Test-Path -path 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Ext\Settings') { 
    # It will not work if any vs is opened
    $p = Get-Process -ProcessName 'devenv' -ErrorAction SilentlyContinue
    if ($null -ne $p) {
      Stop-Process -Id $p.Id
      Start-Sleep -Seconds 60
    }
    
    Remove-Item 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Ext\Settings\' -Recurse 
    }
  }

(Get-ScheduledJob -Name "Clear resharper licence").StartJob()


# .Net Reflector
Register-ScheduledJob -Name "Clear .Net Reflector licence" -Trigger $trigger -ScriptBlock {
  if (Test-Path -Path 'Registry::HKEY_CURRENT_USER\SOFTWARE\Thingummy Software\Licensing\.NET Reflector\') { 
    Remove-Item 'Registry::HKEY_CURRENT_USER\SOFTWARE\Thingummy Software\Licensing\.NET Reflector\' -Recurse 
    }
  }

(Get-ScheduledJob -Name "Clear .Net Reflector licence").StartJob()
