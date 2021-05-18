$trigger = New-JobTrigger -DaysInterval 30 -Daily -At 10:00

# Resharper

Register-ScheduledJob -Name "Clear resharper licence" -Trigger $trigger -ScriptBlock {
  if (Test-Path -path 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Ext\Settings') { 
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
