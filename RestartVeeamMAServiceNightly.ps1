$global:scriptPath = $myinvocation.mycommand.definition

function Restart-AsAdmin {
    $pwshCommand = "powershell"
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        $pwshCommand = "pwsh"
    }

    try {
        Write-Host "This script requires administrator permissions. Attempting to restart script with elevated permissions..."
        $arguments = "-NoExit -Command `"& '$scriptPath'`""
        Start-Process $pwshCommand -Verb runAs -ArgumentList $arguments
        exit 0
    } catch {
        throw "Failed to elevate permissions. Please run this script as Administrator."
    }
}

try {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        if ([System.Environment]::UserInteractive) {
            Restart-AsAdmin
        } else {
            throw "This script requires administrator permissions. Please run this script as Administrator."
        }
    }

    $file = "C:\Scripts\VeeamManagementAgentAutoRestart.ps1"
    try {
        New-Item $file -ItemType File -ErrorAction Stop -Force
        Add-Content $file 'cmd.exe /c "taskkill /F /IM Veeam.MBP.Agent.exe"'
        Add-Content $file 'cmd.exe /c "net start VeeamManagementAgentSvc"'
    } catch {
        $message = $_
        Write-error -Message "Failed to create restart script. $message"
    }

    $trigger = New-ScheduledTaskTrigger -Daily -At "00:00"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -File `"C:\Scripts\VeeamManagementAgentAutoRestart.ps1`""
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    try {
        Register-ScheduledTask -TaskName "RestartVeeamMAServiceNightly" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description "Runs my script once at the specified time"
    } catch {
        $message = $_
        Write-error -Message "Failed to create restart scheduler task. $message"
    }

} catch {
    $message = $_
    Write-error -Message "Failed. $message"
}
