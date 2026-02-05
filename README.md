📄 README – System Report Script (Windows Batch)


📌 Description

This batch script (.bat) generates a detailed system report on Windows, collecting information about hardware, software, users, drivers, processes, storage, and security.
It can run in normal mode or verbose mode (with extended details via PowerShell).
The purpose is auditing and diagnostics without making any configuration changes.

⚙️ Features
- Header Information
- Date and time
- Computer name
- Current user
- Administrator privilege check
- Verbose mode status
- System
- Windows version (ver)
- Hostname (hostname)
- Logged-in users (query user)
- Detailed system info (systeminfo)
- Verbose: CPU, BIOS, uptime, build revision, proxy settings
- Users and Groups
- Local users (net user)
- Local groups (net localgroup)
- Account policies (net accounts)
- Verbose: whoami and user groups
- Drivers
- Driver list (driverquery)
- Verbose: placeholder for extended details
- Tasks and Processes
- Process list (tasklist)
- User processes (query process)
- Verbose: top processes by CPU/memory, running services, event logs
- Storage
- Disk space and volume info (fsutil) – requires admin
- Verbose: volumes, physical disks, BitLocker status
- Security
- Firewall profiles (Get-NetFirewallProfile)
- Microsoft Defender status (Get-MpComputerStatus)
- Verbose: security services, AppLocker policy
- Remote Servers
- Remote Desktop Session Host check (query termserver)

🚀 Usage
- Save the script as system_report.bat or just download it.
- Run it in Command Prompt (CMD) or just double click.
- Normal mode:
system_report.bat
- Verbose mode (extended details via PowerShell):
system_report.bat -v



🔑 Requirements
- Windows 10 or later
- Administrator privileges for advanced sections (storage, BitLocker, AppLocker)
- PowerShell available for verbose commands

⚠️ Important Notes
- The script is read-only: it does not alter configurations, create/delete users, or change policies.
- Some output may include sensitive information (e.g., BIOS serial number, BitLocker status). Use in controlled environments.
- Output can be extensive, especially in verbose mode.

📂 Script Structure
- Main block: collects and displays information.
- Auxiliary functions: :V_* for verbose sections and :SECURITY_ALWAYS for basic security checks.
- Flow control: argument parsing and admin privilege detection.

✅ Conclusion
This script is a system auditing and diagnostic tool for Windows administrators.
It provides a comprehensive overview of the environment without risk of modification or damage.
