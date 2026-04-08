# Script: process-triage.ps1
# Purpose: Quick triage for a target process
# Author: Huynh Huu Dan

Write-Host "=== Process Triage Script ==="

# Cho User nhap ten project vao man hinh
$processName = Read-Host "Enter Process Name (example: notepad)"

# Dieu kien neu user khong nhap thi dung chuong trinh
if ($processName -eq "") {
    Write-Host "Process name cannot be empty."
    exit
}

# Tim process tren may user co dang chay hay khong
$processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

# Neu khong co thi dung
if ($null -eq $processes) {
    Write-Host "No running process found with name: $processName"
    exit
}

# Tao file report 
$reportFile = ".\process-report.txt"

# Thiet lap header noidung cho report
$reportHeader = @"
========================================
Process Triage Report
Target Process : $processName
Generated On   : $(Get-Date)
========================================

"@

Set-Content -Path $reportFile -Value $reportHeader

# Lap qua prcess tim duoc
foreach ($proc in $processes) {

    $pidValue = $proc.Id
    $procNameValue = $proc.ProcessName

    # Path va Hash
    $pathValue = "Unavailable"
    $hashValue = "Unavailable"

    # Lay path cua execute
    if ($proc.Path) {
        $pathValue = $proc.Path
    }

    # Neu co path va file thi lay hash
    if ($pathValue -ne "Unavailable") {
        if (Test-Path $pathValue) {
            $hashValue = (Get-FileHash -Path $pathValue -Algorithm SHA256).Hash
        }
    }

    # Tao noi dung cho process
    $reportBlock = @"
Process Name : $procNameValue
PID          : $pidValue
Path         : $pathValue
SHA256       : $hashValue
Status       : Running

----------------------------------------

"@

   
    Add-Content -Path $reportFile -Value $reportBlock
}

Write-Host ""
Write-Host "Process triage report created successfully!"
Write-Host "Location: $reportFile"