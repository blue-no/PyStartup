if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::
        GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

$name = Read-Host "Task Name"
Write-Host

$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $name }
if (!$taskExists) {
    Write-Host "`"${name}`" does not exist"
    Write-Host
    Write-Host "(Press Enter)"
    Read-Host
    exit
}

Write-Host -NoNewline "Removing ${name}..."
Get-ScheduledTask -TaskName $name | `
    Unregister-ScheduledTask -Confirm:$false

Write-Host "Done"
Write-Host
Write-Host "(Press Enter)"
Read-Host