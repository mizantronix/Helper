function env {
   return ((gci env:*).GetEnumerator() | Sort-Object Name | Out-String)
}

function Clean-Offset {
  <#
  .SYNOPSIS
    Clean offset — stopping connector, delete offsets, resume connector
  .PARAMETER debeziumUrl
    URL for debezium API; '***' for DEV env
  .PARAMETER connectorName
    connector name, witch offset must be cleaned
  #>
  param (
    [Parameter(Mandatory = $true, HelpMessage = "DEV - '***'`nQA - '***'`n")]
    [string] $debeziumUrl,
    [Parameter(Mandatory = $true)]
    [string] $connectorName
  )

  Write-Host "Stopping connector..." -NoNewline
  [void](Invoke-WebRequest "$debeziumUrl/connectors/$connectorName/stop" -Method PUT -UseBasicParsing)
  Write-Host "Done"
  Write-Host "Deleting offsets..." -NoNewline
  [void](Invoke-WebRequest "$debeziumUrl/connectors/$connectorName/offsets" -Method DELETE -UseBasicParsing)
  Write-Host "Done"
  Write-Host "Resuming connector..." -NoNewline
  [void](Invoke-WebRequest "$debeziumUrl/connectors/$connectorName/resume" -Method PUT -UseBasicParsing)
  Write-Host "Done"
}
