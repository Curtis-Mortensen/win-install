# Windows Setup Script

A PowerShell script for automating Windows setup tasks, including privacy-focused registry modifications, application installation, and removal of unnecessary Windows apps.

## Features

- 🛡️ Apply **22** privacy-focused registry modifications
- 🧹 Remove **16** unnecessary Windows applications
- 📝 Detailed logging of all operations
- ⚙️ Configurable via JSON file

## Prerequisites

- Windows PowerShell 5.1 or later
- Administrator privileges
- [Windows Package Manager (winget)](https://docs.microsoft.com/en-us/windows/package-manager/winget/)

## Installation

1. Clone this repository:
bash
git clone [your-repo-url]

3. Configure your desired registry changes and applications in `RegistryChanges.json`

## Usage

1. Right-click on `win-install.ps1` and select "Run with PowerShell as Administrator"
   
   OR

2. Open PowerShell as Administrator and run:
powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\win-install.ps1

The script will guide you through three optional operations:
1. Applying registry modifications
2. Installing new applications
3. Removing unnecessary Windows apps

## Configuration

Configure your desired registry changes and applications in `win-setup-config.json`

## Logging

All operations are logged to the `Logs` directory with timestamps. Each run creates a new log file with format: `Registry_Changes_YYYYMMDD_HHMMSS.log`

## Safety Features

- Requires explicit administrator privileges
- Checks for winget availability
- Validates registry paths before modifications
- Includes fallback paths for registry changes
- Provides detailed logging of all operations
- Asks for confirmation before each major operation

## 🤖 AI Collaboration Note

This project was developed in collaboration with AI (Claude 3.5 Sonnet). The AI assisted in:
- Script structure and logic
- Documentation and README creation
- Best practices implementation
- Error handling and logging features

While AI was used as a development tool, all code has been reviewed and tested by a human in the loop for functionality and security. 

## Contributions

Contributions are welcome! If you're interested in improving this project, please feel free to submit a Pull Request.

## License

AGPL 3.0

## Disclaimer

Please review all registry modifications and application changes before running the script. Always backup your registry before making modifications.
