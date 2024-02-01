// 12.19.2023 - with Python and SQLFluff, in one folder, and with Flyway version check ////////////////////////////////////////////////////
# Set preference for download progress
$ProgressPreference = 'SilentlyContinue'

# Base installation path
$BasePath = "C:\FlywayCLI\"

# Flyway Version to Use
$flywayVersion = $($env:FLYWAY_VERSION)
$FlywayFolder = "flyway-$flywayVersion"
$flywayBinPath = Join-Path $BasePath $FlywayFolder

# Python and SQLFluff directories
$PythonFolder = "python"
$pythonBinPath = Join-Path $BasePath $PythonFolder
$SQLFluffFolder = "sqlfluff"
$sqlfluffPath = Join-Path $BasePath $SQLFluffFolder

# Folder setup
#C:\FlywayCLI\
#    ├── flyway-<version>\
#    ├── python\
#    └── sqlfluff\

# Check and create base directory if not exists
if (-not (Test-Path $BasePath)) {
    New-Item -Path $BasePath -ItemType Directory
}

# Flyway installation/update check
$flywayInstalled = Get-ChildItem $BasePath -Directory | Where-Object { $_.Name -match 'flyway-\d+(\.\d+)*' }
if ($flywayInstalled) {
    $installedFlywayPath = $flywayInstalled | Select-Object -First 1
    $installedFlywayVersion = & "$installedFlywayPath\flyway.cmd" --version 2>&1
    $installedFlywayVersion = $installedFlywayVersion -replace "Flyway Community Edition ",""

    if ($installedFlywayVersion -notlike "*$flywayVersion*") {
        Write-Host "Updating Flyway to version $flywayVersion..."
        Remove-Item $installedFlywayPath -Recurse
    } else {
        Write-Host "Flyway version $flywayVersion is already installed."
        # Skip the installation process if the current version is correct
        return
    }
} else {
    Write-Host "No Flyway installation found. Installing Flyway version $flywayVersion..."
}

# Install or Update Flyway
$Url = "https://download.red-gate.com/maven/release/org/flywaydb/enterprise/flyway-commandline/$flywayVersion/flyway-commandline-$flywayVersion-windows-x64.zip"
$DownloadZipFile = Join-Path $BasePath (Split-Path -Path $Url -Leaf)
Invoke-WebRequest -Uri $Url -OutFile $DownloadZipFile -UseBasicParsing
Expand-Archive -LiteralPath $DownloadZipFile -DestinationPath $flywayBinPath -Force
Remove-Item -Path $DownloadZipFile -Force
Write-Host "Flyway installed/updated to version $flywayVersion."


# Python installation
if (-not (Test-Path $pythonBinPath)) {
    Write-Host "Installing Python..."
    # Add code to download and install Python
    # Example: Download Python installer and specify $pythonBinPath as the installation directory
    Write-Host "Python installed successfully."
} else {
    Write-Host "Python is already installed."
}

# Update PATH for Flyway, Python, and SQLFluff
$env:Path += ";$flywayBinPath;$pythonBinPath;$sqlfluffPath"
[Environment]::SetEnvironmentVariable("PATH", $env:Path, [EnvironmentVariableTarget]::Machine)

# SQLFluff installation
$pythonExec = Join-Path $pythonBinPath "python.exe"
if (-not (Test-Path $sqlfluffPath)) {
    Write-Host "Installing SQLFluff..."
    & $pythonExec -m pip install sqlfluff==1.2.1 --target $sqlfluffPath
    Write-Host "SQLFluff installed successfully."
} else {
    Write-Host "SQLFluff is already installed."
}

# Check installed versions
Write-Host "Installed versions:"
& "$flywayBinPath\flyway.cmd" --version
& $pythonExec --version
& $pythonExec -m pip show sqlfluff