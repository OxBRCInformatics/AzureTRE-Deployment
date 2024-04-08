
function Write-Log {
    param (
        $message
    )

    $formattedTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "$formattedTime init_vm: $message"
}

function Create-DesktopShortcut {
    param (
        [string]$AppName,
        [string]$ExecutablePath
    )

    $shell = New-Object -comObject WScript.Shell
    $shortcut = $shell.CreateShortcut("C:\Users\Public\Desktop\$AppName.lnk")  # Adjust the path and name as needed
    $shortcut.TargetPath = "$INSTALL_DIRECTORY\$AppName\$ExecutablePath"  # Corrected path of the executable
    $shortcut.Save()

}
ß

$BUILD_DIRECTORY="C:\BuildArtifacts"
$INSTALL_DIRECTORY="C:\Software"

Write-Log "Create Directories"
New-Item -Path $BUILD_DIRECTORY -ItemType Directory
New-Item -Path $INSTALL_DIRECTORY -ItemType Directory

Set-Location -Path $BUILD_DIRECTORY

# Python
$PYTHON_INSTALLER_FILE="python-3.10.7-amd64.exe"
$PYTHON_DOWNLOAD_URL="https://www.python.org/ftp/python/3.10.7/$PYTHON_INSTALLER_FILE"
$PYTHON_INSTALL_PATH="$INSTALL_DIRECTORY\Python3"
$PYTHON_INSTALL_ARGS="/quiet InstallAllUsers=1 PrependPath=1 Include_test=0 TargetDir=$PYTHON_INSTALL_PATH"

Write-Log "Downloading Python3 installer..."
Invoke-WebRequest -Uri $PYTHON_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$PYTHON_INSTALLER_FILE"

Write-Log "Installing Python3..."
Start-Process $PYTHON_INSTALLER_FILE -ArgumentList $PYTHON_INSTALL_ARGS -Wait


# ANACONDA
$ANACONDA_INSTALLER_FILE="Anaconda3-2022.05-Windows-x86_64.exe"
$ANACONDA_DOWNLOAD_URL="https://repo.anaconda.com/archive/$ANACONDA_INSTALLER_FILE"
$ANACONDA_INSTALL_PATH="$INSTALL_DIRECTORY\Anaconda3"
$ANACONDA_INSTALL_ARGS="/InstallationType=AllUsers /RegisterPython=0 /S /D=$ANACONDA_INSTALL_PATH"

Write-Log "Downloading Anaconda installer..."
Invoke-WebRequest -Uri $ANACONDA_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$ANACONDA_INSTALLER_FILE"

Write-Log "Installing Anaconda..."
Start-Process $ANACONDA_INSTALLER_FILE -ArgumentList $ANACONDA_INSTALL_ARGS -Wait


# VSCODE
$VSCODE_INSTALLER_FILE="VSCodeSetup-x64-1.87.2.exe"
$VSCODE_DOWNLOAD_URL="https://update.code.visualstudio.com/1.87.2/win32-x64/stable"
$VSCODE_INSTALL_PATH="$INSTALL_DIRECTORY\VSCode"
$VSCODE_EXTENSION_PATH="$VSCODE_INSTALL_PATH\extensions"
$VSCODE_INSTALL_ARGS="/VERYSILENT /DIR=$VSCODE_INSTALL_PATH /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"
$VSCODE_INSTALL_PATH="$INSTALL_DIRECTORY\VSCode"
[Environment]::SetEnvironmentVariable("VSCODE_EXTENSIONS", "$VSCODE_EXTENSION_PATH", [EnvironmentVariableTarget]::Machine)


Write-Log "Downloading VSCode system installer..."
Invoke-WebRequest -Uri $VSCODE_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$VSCODE_INSTALLER_FILE"


Write-Log "Installing VSCode..."
Start-Process $VSCODE_INSTALLER_FILE -ArgumentList $VSCODE_INSTALL_ARGS -Wait

New-Item -Path $VSCODE_EXTENSION_PATH -ItemType Directory

# See https://code.visualstudio.com/docs/editor/command-line#_working-with-extensions
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension ms-python.python --force" -Wait
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension REditorSupport.r --force" -Wait
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension RDebugger.r-debugger --force" -Wait

# Create Desktop shortcutß
Create-DesktopShortcut -AppName "VSCode" -ExecutablePath "Code.exe"

# ProM Tool
$PROM_INSTALLER_FILE="prom-6.11-jre8-installer.exe"
$PROM_DOWNLOAD_URL="http://promtools.org/prom6/downloads/$PROM_INSTALLER_FILE"
$PROM_INSTALL_PATH="$INSTALL_DIRECTORY\Prom6"
$PROM_INSTALL_ARGS="--mode unattended --prefix $PROM_INSTALL_PATH"

Write-Log "Downloading ProM6 installer..."
Invoke-WebRequest -Uri $PROM_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$PROM_INSTALLER_FILE"

Write-Log "Installing ProM6..."
Start-Process $PROM_INSTALLER_FILE -ArgumentList $PROM_INSTALL_ARGS -Wait


# R
$R_INSTALLER_FILE="R-4.3.3-win.exe"
$R_DOWNLOAD_URL="https://cran.ma.imperial.ac.uk/bin/windows/base/$R_INSTALLER_FILE"
$R_INSTALL_PATH="$INSTALL_DIRECTORY\R"
$R_INSTALL_ARGS="/VERYSILENT /NORESTART /ALLUSERS /DIR=$R_INSTALL_PATH"


Write-Log "Downloading R-Base Package installer..."
Invoke-WebRequest -Uri $R_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$R_INSTALLER_FILE"

Write-Log "Installing R-Base Package..."
Start-Process $R_INSTALLER_FILE -ArgumentList $R_INSTALL_ARGS -Wait


# RTools - This need to be install at the default location to avoid rtools not found errors.
$RTools_INSTALLER_FILE="rtools43-5958-5975.exe"
$RTools_DOWNLOAD_URL="https://cran.r-project.org/bin/windows/Rtools/rtools43/files/$RTools_INSTALLER_FILE"
$RTools_INSTALL_ARGS="/VERYSILENT /NORESTART /ALLUSERS"

Write-Log "Downloading RTools installer..."
Invoke-WebRequest -Uri $RTools_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$RTools_INSTALLER_FILE"

Write-Log "Installing RTools..."
Start-Process $RTools_INSTALLER_FILE -ArgumentList $RTools_INSTALL_ARGS -Wait


# RStudio
$RStudio_INSTALLER_FILE="RStudio-2023.12.1-402.exe"
$RStudio_DOWNLOAD_URL="https://s3.amazonaws.com/rstudio-ide-build/electron/windows/$RStudio_INSTALLER_FILE"
$RStudio_INSTALL_PATH="$INSTALL_DIRECTORY\RStudio"
$RStudio_INSTALL_ARGS="/S /D=$RStudio_INSTALL_PATH"


Write-Log "Downloading RStudio Package installer..."
Invoke-WebRequest -Uri $RStudio_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$RStudio_INSTALLER_FILE"

Write-Log "Installing RStudio Package..."
Start-Process $RStudio_INSTALLER_FILE -ArgumentList $RStudio_INSTALL_ARGS -Wait

# Create Desktop shortcutß
Create-DesktopShortcut -AppName "Rstudio" -ExecutablePath "rstudio.exe"

#.Net Runtime 4.8
$DotNet_INSTALLER_FILE="ndp481-x86-x64-allos-enu.exe"
$DotNet_DOWNLOAD_URL="https://go.microsoft.com/fwlink/?linkid=2203305"
$DotNet_INSTALL_ARGS="/q /norestart"

Write-Log "Downloading .Net Runtime installer..."
Invoke-WebRequest -Uri $DotNet_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$DotNet_INSTALLER_FILE"

Write-Log "Installing .Net Runtime..."
Start-Process $DotNet_INSTALLER_FILE -ArgumentList $DotNet_INSTALL_ARGS -Wait


# Azure Storage Explorer
$StorageExplorer_INSTALLER_FILE="StorageExplorer.exe"
$StorageExplorer_DOWNLOAD_URL="https://go.microsoft.com/fwlink/?LinkId=708343&clcid=0x809"
$StorageExplorer_INSTALL_PATH="$INSTALL_DIRECTORY\StorageExplorer"
$StorageExplorer_INSTALL_ARGS="/VERYSILENT /NORESTART /ALLUSERS /DIR=$StorageExplorer_INSTALL_PATH"

Write-Log "Downloading Azure Storage Explorer installer..."
Invoke-WebRequest -Uri $StorageExplorer_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$StorageExplorer_INSTALLER_FILE"

Write-Log "Installing Azure Storage Explorer..."
Start-Process $StorageExplorer_INSTALLER_FILE -ArgumentList $StorageExplorer_INSTALL_ARGS -Wait

# Create Desktop shortcutß
Create-DesktopShortcut -AppName "StorageExplorer" -ExecutablePath "StorageExplorer.exe"


# PostgreSQL
$PostgreSQL_INSTALLER_FILE="StorageExplorer.exe"
$PostgreSQL_DOWNLOAD_URL="https://sbp.enterprisedb.com/getfile.jsp?fileid=1258212"
$PostgreSQL_INSTALL_ARGS="--mode unattended"

Write-Log "Downloading PostgreSQL installer..."
Invoke-WebRequest -Uri $PostgreSQL_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$PostgreSQL_INSTALLER_FILE"

Write-Log "Installing PostgreSQL..."
Start-Process $PostgreSQL_INSTALLER_FILE -ArgumentList $PostgreSQL_INSTALL_ARGS -Wait

# nvidia driver
New-Item -Path $INSTALL_DIRECTORY\NVIDIA -ItemType Directory
$NVIDIA_INSTALLER_FILE="527.41-data-center-tesla-desktop-win10-win11-64bit-dch-international.exe"
$NVIDIA_DOWNLOAD_URL="https://uk.download.nvidia.com/tesla/527.41/$NVIDIA_INSTALLER_FILE"
$NVIDIA_INSTALL_PATH="$INSTALL_DIRECTORY\NVIDIA"

Write-Log "Downloading NVIDIA installer..."
Invoke-WebRequest -Uri $NVIDIA_DOWNLOAD_URL -UseBasicParsing -OutFile "$NVIDIA_INSTALL_PATH\$NVIDIA_INSTALLER_FILE"

# git
$git_INSTALLER_FILE="Git-2.43.0-64-bit.exe"
$git_DOWNLOAD_URL="https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/$git_INSTALLER_FILE"
$git_INSTALL_PATH="$INSTALL_DIRECTORY\git"
$git_INSTALL_ARGS="/SILENT /DIR=$git_INSTALL_PATH"

Write-Log "Downloading git installer..."
Invoke-WebRequest -Uri $git_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$git_INSTALLER_FILE"

Write-Log "Installing git..."
Start-Process $git_INSTALLER_FILE -ArgumentList $git_INSTALL_ARGS -Wait

# LibreOffice
$libreoffice_INSTALLER_FILE="LibreOffice_7.4.7_Win_x64.msi"
$Libreoffice_DOWNLOAD_URL="https://www.libreoffice.org/download/download/$libreoffice_INSTALLER_FILE"
$Libreoffice_INSTALL_PATH="INSTALL_DIRECTORY\LibreOffice"
$Libreoffice_INSTALL_ARGS="RebootYesNo=No /qn"

Write-Log "Downloading Libreoffice installer..."
Invoke-WebRequest -Uri $Libreoffice_DOWNLOAD_URL -UseBasicParsing -OutFile "$BUILD_DIRECTORY\$libreoffice_INSTALLER_FILE"

Write-Log "Installing Libreoffice..."
Start-Process $libreoffice_INSTALLER_FILE -ArgumentList $Libreoffice_INSTALL_ARGS -Wait

# PATH
Write-Log "Add Anaconda and R to PATH environment variable"
[Environment]::SetEnvironmentVariable("PATH", "$Env:PATH;$ANACONDA_INSTALL_PATH\condabin;$R_INSTALL_PATH\bin;$PYTHON_INSTALL_PATH\Scripts", [EnvironmentVariableTarget]::Machine)


# Write-Log "Clean up..."
Set-Location -Path "$INSTALL_DIRECTORY"
Remove-Item -Path "C:\buildArtifacts\*" -Force -Recurse
Remove-Item -Path "C:\buildArtifacts" -Force

Write-Log "VM customisation complete."

