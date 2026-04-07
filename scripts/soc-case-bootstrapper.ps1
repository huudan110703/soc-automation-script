# Script: soc-close-case-bootstrapper.ps1
# Purpose: Create a SOC close-case folder with a full investigation template
# Author: Huynh Huu Dan

Write-Host "=== SOC Close Case Bootstrapper ==="

# Nhập thông tin từ user
$caseId = Read-Host "Enter Case ID "
$hostname = Read-Host "Enter Hostname / Affected Device"
$alertName = Read-Host "Enter Alert Name"
$severity = Read-Host "Enter Severity (Low/Medium/High)"
$status = Read-Host "Enter Status (True Positive / False Positive / Indeterminate / Other)"

if ($caseId -eq "") {
    $caseId = "Case-001"
}

if ($hostname -eq "") {
    $hostname = "Unknown-Host"
}

if ($alertName -eq "") {
    $alertName = "Unknown-Alert"
}

if ($severity -eq "") {
    $severity = "Medium"
}

if ($status -eq "") {
    $status = "Indeterminate"
}

# Khai bao bien caseFolder de tao  duong dan o vi tri hien tai, dong thoi tao 1 foder envidence ben trong
$caseFolder = ".\$caseId"
$evidenceFolder = "$caseFolder\evidence"

# Kiem tra xem bien nay da ton tai hay chua 
if (Test-Path $caseFolder) {
    Write-Host "Case folder already exists: $caseFolder"
    exit
}

# Tao folder chinh va folder evidence
New-Item -Path $caseFolder -ItemType Directory | Out-Null
New-Item -Path $evidenceFolder -ItemType Directory | Out-Null

# Tao file close-case-template.txt voi full format
$closeCaseContent = @"
Case ID   : $caseId
Alert Name: $alertName
Hostname  : $hostname
Severity  : $severity
Status    : $status
Created On: $(Get-Date)

==================================================
Description
==================================================

1. Phân tích các cảnh báo.

2. Tìm kiếm, gom nhóm các alert liên quan.

3. Tổng hợp thông tin theo mẫu sau:

- Nguồn dữ liệu tình báo (Threat Intelligence Source):
- Tên thiết bị nội bộ bị ảnh hưởng (Affected Internal Device Name):
- Địa chỉ IP của thiết bị nội bộ (Internal Device IP Address):
- Loại hình chỉ báo (Indicator Type - e.g., IP, URL, domain, hash):
- Giá trị chỉ báo (Indicator Value):
- Mức độ nghiêm trọng (Indicator Severity - e.g., low, medium, high):
- Nguồn gốc chỉ báo (Indicator Origin - e.g., open-source, commercial provider):
- Ngày phát hiện chỉ báo (Indicator First Seen Date):
- Ngày cập nhật cuối cùng (Indicator Last Updated Date):
- Chỉ báo liên quan đến nhóm tấn công nào (Associated Threat Actor Group):
- Ngữ cảnh (Context of Use - e.g., phishing campaign, ransomware attack):
- Chỉ số MITRE ATT&CK (MITRE ATT&CK Tactics/Techniques):
- Số lần phát hiện chỉ báo trong hệ thống (Occurrences in internal environment):
- Danh sách hệ thống bị ảnh hưởng (List of affected systems):
- Tình trạng phản hồi (Status of response - e.g., completed, in progress):
- Thông tin bổ sung (Additional intelligence - e.g., related indicators, past incidents):

==================================================
Status
==================================================

- True Positive
- False Positive
- Indeterminate
- Other

Selected Status: $status

==================================================
Summary
==================================================


==================================================
Task Logs
==================================================

- Add new task log here if needed.

==================================================
Analyst Notes
==================================================


"@

Set-Content -Path "$caseFolder\close-case-template.txt" -Value $closeCaseContent

# Tạo file timeline.csv
$timelineContent = @"
Time,Event,Details
$(Get-Date),Case Created,Initial case folder and template created
"@

Set-Content -Path "$caseFolder\timeline.csv" -Value $timelineContent

# Tạo file task-log.csv
$taskLogContent = @"
Time,Task,Status,Notes
$(Get-Date),Case bootstrap created,Completed,Initial structure created by script
"@

Set-Content -Path "$caseFolder\task-log.csv" -Value $taskLogContent

# Tao file host-info.txt
$hostInfoContent = @"
=== Host Information ===

Alert Name     : $alertName
Hostname       : $hostname
Severity       : $severity
Status         : $status
Current User   : $env:USERNAME
Computer Name  : $env:COMPUTERNAME
Created On     : $(Get-Date)
"@

Set-Content -Path "$caseFolder\host-info.txt" -Value $hostInfoContent

# Tao file summary.txt rieng
$summaryContent = @"
Case ID   : $caseId
Alert Name: $alertName
Hostname  : $hostname
Severity  : $severity
Status    : $status

Summary:
"@

Set-Content -Path "$caseFolder\summary.txt" -Value $summaryContent

Write-Host ""
Write-Host "SOC case template created successfully!"
Write-Host "Location: $caseFolder"
Write-Host ""
Write-Host "Created items:"
Write-Host "- close-case-template.txt"
Write-Host "- timeline.csv"
Write-Host "- task-log.csv"
Write-Host "- host-info.txt"
Write-Host "- summary.txt"
Write-Host "- evidence\"