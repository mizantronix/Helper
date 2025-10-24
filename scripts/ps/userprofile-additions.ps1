function env {
   return ((gci env:*).GetEnumerator() | Sort-Object Name | Out-String)
}