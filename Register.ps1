$WinpythonPath = "D:\projects\pytheme\.venv\Scripts\pythonw.exe"

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::
        GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

$command = Read-Host('Command after "python"')
$name = Read-Host('Task name')
if ($command -eq "") { exit }
$parentPath = Split-Path $WinpythonPath.Replace("`"", "")

Write-Host
$taskExists = Get-ScheduledTask | Where-Object { $_.TaskName -like $name }
if ($taskExists) {
    Write-Host -NoNewline "Removing existing `"${name}`"..."
    Get-ScheduledTask -TaskName $name | `
        Unregister-ScheduledTask -Confirm:$false
    Write-Host "Done"
}

Write-Host -NoNewline "Registering command `"python ${command}`" as `"${name}`"..."
$action = New-ScheduledTaskAction `
    -Execute  ${WinpythonPath} `
    -Argument "${command}" `
    -WorkingDirectory "${parentPath}" `

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -DontStopOnIdleEnd `
    -Hidden `
    -MultipleInstances IgnoreNew `
    -RestartCount 5 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -StartWhenAvailable

$trigger = New-ScheduledTaskTrigger `
    -AtLogOn

$task = Register-ScheduledTask `
    -TaskName $name `
    -Action $action `
    -Settings $settings `
    -Trigger $trigger

Write-Host "Done"
Write-Host
Write-Host "(Press Enter)"
Read-Host