# REGISTRY CHANGES
#Requires -RunAsAdministrator
#Requires -Version 5.1

# Script constants
$CONFIG_PATH = Join-Path $PSScriptRoot "win-setup-config.json"
$LOG_PATH = Join-Path $PSScriptRoot "Logs\Registry_Changes_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Load configuration
$config = Get-Content $CONFIG_PATH | ConvertFrom-Json

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator"
    exit 1
}

# Check if winget is installed
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed. Please install it first."
    exit 1
}

# Function to write to both log and console
function Write-LogMessage {
    param(
        [string]$Message,
        [ValidateSet('Info','Error','Success')]
        [string]$Type = 'Info'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Type] $Message"
    
    # Write to log file
    Add-Content -Path $LOG_PATH -Value $logMessage
    
    # Write to console with appropriate color
    switch ($Type) {
        'Error'   { Write-Host $logMessage -ForegroundColor Red }
        'Success' { Write-Host $logMessage -ForegroundColor Green }
        default   { Write-Host $logMessage }
    }
}

# Add welcome message and confirmation functions
function Get-UserConfirmation {
    param(
        [string]$Message
    )
    $response = Read-Host "$Message (y/n)"
    return $response.ToLower() -eq 'y'
}

# Add this section at the start of the main execution
Write-Host "`n=== Windows Setup Script ===`n" -ForegroundColor Cyan
Write-Host "Welcome! This script can help you with three main tasks:"
Write-Host "1. Apply privacy-focused registry modifications"
Write-Host "2. Install new applications"
Write-Host "3. Remove unnecessary Windows apps`n"

$doRegistry = Get-UserConfirmation "Would you like to apply privacy-focused registry modifications?"
$doInstall = Get-UserConfirmation "Would you like to install new applications?"
$doUninstall = Get-UserConfirmation "Would you like to remove unnecessary Windows apps?"



# REGISTRY CHANGES

if ($doRegistry) {
    Write-LogMessage "Starting registry customization process" -Type Info

# Function to find valid registry path
function Find-ValidRegistryPath {
    param(
        [string]$PrimaryPath,
        [string[]]$FallbackPaths
    )
    
    if (Test-Path $PrimaryPath) {
        return $PrimaryPath
    }
    
    foreach ($path in $FallbackPaths) {
        if (Test-Path $path) {
            Write-LogMessage "Using fallback path: $path" -Type Info
            return $path
        }
    }
    
    return $null
}

# Function to apply registry change
function Set-RegistryCustomization {
    param(
        [PSCustomObject]$Change
    )
    
    $validPath = Find-ValidRegistryPath -PrimaryPath $Change.path -FallbackPaths $Change.fallback_paths
    
    if (-not $validPath) {
        Write-LogMessage "No valid registry path found for: $($Change.description)" -Type Error
        return $false
    }
    
    try {
        # Ensure registry key path exists
        $keyPath = Split-Path $validPath
        if (-not (Test-Path $keyPath)) {
            New-Item -Path $keyPath -Force | Out-Null
            Write-LogMessage "Created new registry key path: $keyPath" -Type Info
        }
        
        # Set registry value
        Set-ItemProperty -Path $validPath -Name $Change.name -Value $Change.value -Type $Change.type -ErrorAction Stop
        Write-LogMessage "Successfully applied: $($Change.description)" -Type Success
        return $true
    }
    catch {
        Write-LogMessage "Failed to apply: $($Change.description). Error: $_" -Type Error
        return $false
    }
}

# Main execution
try {
    # Create Logs directory if it doesn't exist
    New-Item -ItemType Directory -Force -Path (Split-Path $LOG_PATH) | Out-Null
    
    Write-LogMessage "Starting registry customization process" -Type Info
    
    # Track statistics
    $totalChanges = $config.registry_changes.Count
    $successCount = 0
    
    # Apply each change
    foreach ($change in $config.registry_changes) {
        if (Set-RegistryCustomization -Change $change) {
            $successCount++
        }
    }
    
    # Summary
    Write-Host "Settings have been applied. Some changes might require a system restart to take effect."
    Write-LogMessage "Completed: $successCount of $totalChanges changes successful" -Type Info
}
catch {
    Write-LogMessage "Critical error: $_" -Type Error
}
finally {
    Write-LogMessage "Process completed. Log file: $LOG_PATH" -Type Info
    }
}


# INSTALL APPLICATIONS

if ($doInstall) {
    Write-LogMessage "Starting application installation" -Type Info
    
    $totalApps = $config.install.winget_packages.Count
    $currentApp = 0
    
    foreach ($app in $config.install.winget_packages) {
        $currentApp++
        Write-Progress -Activity "Installing Applications" -Status "Installing $app" -PercentComplete (($currentApp / $totalApps) * 100)
        
        Write-LogMessage "Installing $app..." -Type Info
        try {
            $result = winget install -e --accept-source-agreements --accept-package-agreements $app
            if ($LASTEXITCODE -eq 0) {
                Write-LogMessage "Successfully installed $app" -Type Success
            } else {
                Write-LogMessage "Installation failed for $app with exit code $LASTEXITCODE" -Type Error
            }
        }
        catch {
            Write-LogMessage "Failed to install $app. Error: $_" -Type Error
        }
    }
    
    Write-Progress -Activity "Installing Applications" -Completed
}



# UNINSTALL APPLICATIONS    

if ($doUninstall) {
    Write-LogMessage "Starting application uninstallation" -Type Info
    
    $totalApps = $config.uninstall.winget_packages.Count
    $currentApp = 0
    
    foreach ($app in $config.uninstall.winget_packages) {
        $currentApp++
        Write-Progress -Activity "Uninstalling Applications" -Status "Removing $app" -PercentComplete (($currentApp / $totalApps) * 100)
        
        Write-LogMessage "Uninstalling $app..." -Type Info
        try {
            $result = winget uninstall --accept-source-agreements --silent $app
            if ($LASTEXITCODE -eq 0) {
                Write-LogMessage "Successfully uninstalled $app" -Type Success
            } else {
                Write-LogMessage "Uninstallation failed for $app with exit code $LASTEXITCODE" -Type Error
            }
        }
        catch {
            Write-LogMessage "Failed to uninstall $app. Error: $_" -Type Error
        }
    }
    
    Write-Progress -Activity "Uninstalling Applications" -Completed
}
