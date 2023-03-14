# Check if the script is running with administrative privileges and relaunch it as an administrator if not
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define variables for the ODBC driver
$sqlServerDriverUrl = "https://dev.mysql.com/get/Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.32-winx64.msi"

# Define the paths for downloading and installing the driver
$downloadPath = "$env:USERPROFILE\Downloads"
$installPath = "C:\Drivers"

# Create the install path directory if it doesn't already exist
if (-not (Test-Path -Path $installPath -PathType Container)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}

# Download and install the MySQL driver
$mysqlDriverFileName = "mysql-connector-odbc-8.0.32-winx64.msi"
$mysqlDriverDownloadUrl = "$sqlServerDriverUrl/$mysqlDriverFileName"
$mysqlDriverDownloadPath = Join-Path $downloadPath $mysqlDriverFileName
$mysqlDriverInstallPath = Join-Path $installPath $mysqlDriverFileName

Invoke-WebRequest -Uri $mysqlDriverDownloadUrl -OutFile $mysqlDriverDownloadPath
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$mysqlDriverDownloadPath`" /qn /L*V `"$env:USERPROFILE\mysql.log`" INSTALLDIR=`"$mysqlDriverInstallPath`"" -Wait

# Launch the ODBC Data Source Administrator program as an administrator
Start-Process "odbcad32.exe" -Verb RunAs

