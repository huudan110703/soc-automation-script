# Script: persistence-checker.ps1
# Purpose: Check common Windows persistence locations
# Author: Huynh Huu Dan

Write-Host "=== Persistence Checker Script ==="

# Tạo file report
$reportFile = ".\persistence-report.txt"

# Tạo phần đầu report
$reportHeader = @"
========================================
Persistence Check Report
Generated On : $(Get-Date)
Computer Name: $env:COMPUTERNAME
Current User : $env:USERNAME
========================================

"@

Set-Content -Path $reportFile -Value $reportHeader

# Danh sách registry paths cần check
$registryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
)

# Check từng registry path
foreach ($regPath in $registryPaths) {

    Add-Content -Path $reportFile -Value "[$regPath]"

    if (Test-Path $regPath) {
        $regItem = Get-ItemProperty -Path $regPath

        # Lấy danh sách property, bỏ bớt property mặc định của PowerShell
        $properties = $regItem.PSObject.Properties | Where-Object {
            $_.Name -notlike "PS*"
        }

        if ($null -eq $properties -or $properties.Count -eq 0) {
            Add-Content -Path $reportFile -Value "No entries found."
            Add-Content -Path $reportFile -Value ""
        }
        else {
            foreach ($prop in $properties) {
                Add-Content -Path $reportFile -Value "Value Name : $($prop.Name)"
                Add-Content -Path $reportFile -Value "Value Data : $($prop.Value)"
                Add-Content -Path $reportFile -Value "----------------------------------------"
            }
            Add-Content -Path $reportFile -Value ""
        }
    }
    else {
        Add-Content -Path $reportFile -Value "Path does not exist."
        Add-Content -Path $reportFile -Value ""
    }
}

# Startup folder paths
$currentUserStartup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$allUsersStartup = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"

$startupFolders = @(
    $currentUserStartup,
    $allUsersStartup
)

# Check từng startup folder
foreach ($startupPath in $startupFolders) {

    Add-Content -Path $reportFile -Value "[Startup Folder: $startupPath]"

    if (Test-Path $startupPath) {
        $startupItems = Get-ChildItem -Path $startupPath

        if ($null -eq $startupItems -or $startupItems.Count -eq 0) {
            Add-Content -Path $reportFile -Value "No startup items found."
            Add-Content -Path $reportFile -Value ""
        }
        else {
            foreach ($item in $startupItems) {
                Add-Content -Path $reportFile -Value "Name : $($item.Name)"
                Add-Content -Path $reportFile -Value "Full Path : $($item.FullName)"
                Add-Content -Path $reportFile -Value "Last Write Time : $($item.LastWriteTime)"
                Add-Content -Path $reportFile -Value "----------------------------------------"
            }
            Add-Content -Path $reportFile -Value ""
        }
    }
    else {
        Add-Content -Path $reportFile -Value "Startup folder does not exist."
        Add-Content -Path $reportFile -Value ""
    }
}

Write-Host ""
Write-Host "Persistence report created successfully!"
Write-Host "Location: $reportFile"