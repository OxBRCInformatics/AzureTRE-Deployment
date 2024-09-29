Remove-Item -LiteralPath "C:\AzureData" -Force -Recurse
$ErrorActionPreference = "Stop"

if( ${SharedStorageAccess} -eq 1 )
{
  $Command = "net use z: \\${StorageAccountFileHost}\${FileShareName} /u:AZURE\${StorageAccountName} ${StorageAccountKey}"
  $Command | Out-File  "C:\ProgramData\Start Menu\Programs\StartUp\attach_storage.cmd" -encoding ascii
}

$PipConfigFolderPath = "C:\ProgramData\pip\"
If(!(Test-Path $PipConfigFolderPath))
{
  New-Item -ItemType Directory -Force -Path $PipConfigFolderPath
}

$PipConfigFilePath = $PipConfigFolderPath + "pip.ini"

$ConfigBody = @"
[global]
index = ${nexus_proxy_url}/repository/pypi/pypi
index-url = ${nexus_proxy_url}/repository/pypi/simple
trusted-host = ${nexus_proxy_url}
"@

# We need to write the ini file in UTF8 (No BOM) as pip won't understand Powershell's default encoding (unicode)
$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllLines($PipConfigFilePath, $ConfigBody, $Utf8NoBomEncoding)

### Anaconda Config
if( ${CondaConfig} -eq 1 )
{
  conda config --add channels ${nexus_proxy_url}/repository/conda-mirror/main/  --system
  conda config --add channels ${nexus_proxy_url}/repository/conda-repo/main/  --system
  conda config --remove channels defaults --system
  conda config --set channel_alias ${nexus_proxy_url}/repository/conda-mirror/  --system
}

# Define the download URL and output path
$libreOfficeUrl = "https://download.documentfoundation.org/libreoffice/stable/24.2.6/win/x86_64/LibreOffice_24.2.6_Win_x86-64.msi"
$installerPath = "C:\BuildArtifacts\LibreOffice_24.2.6_Win_x86-64.msi"

# Download the LibreOffice installer
Invoke-WebRequest -Uri $libreOfficeUrl -OutFile $installerPath

# Wait for the download to complete
Write-Host "LibreOffice installer downloaded."

# Install LibreOffice silently (no user interaction)
Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /quiet /norestart" -Wait

# Clean up the installer file after installation
Remove-Item $installerPath

Write-Host "LibreOffice has been installed."

# Define the installer file and URL for the latest version
$VSCODE_DOWNLOAD_URL = "https://update.code.visualstudio.com/latest/win32-x64/stable"
$VSCODE_INSTALLER_FILE = "VSCodeSetup.exe"
$VSCODE_INSTALL_PATH = "C:\Program Files\Microsoft VS Code"

# Download the latest installer
Invoke-WebRequest -Uri $VSCODE_DOWNLOAD_URL -OutFile $VSCODE_INSTALLER_FILE

# Install or update Visual Studio Code
Start-Process -FilePath $VSCODE_INSTALLER_FILE -ArgumentList "/VERYSILENT /DIR=$VSCODE_INSTALL_PATH /MERGETASKS=!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath" -Wait

# Remove the installer file after installation
Remove-Item $VSCODE_INSTALLER_FILE

### Additional VS code extensions
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension njpwerner.autodocstring --force" -Wait
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension ms-python.data-wrangler --force" -Wait
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension GrapeCity.gc-excelviewer --force" -Wait
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension formulahendry.auto-complete --force" -Wait
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension KevinRose.vsc-python-indent --force" -Wait
Start-Process "$VSCODE_INSTALL_PATH\bin\code" -ArgumentList "--extensions-dir $VSCODE_EXTENSION_PATH --install-extension Gruntfuggly.todo-tree --force" -Wait

# Docker proxy config
$DaemonConfig = @"
{
"registry-mirrors": ["${nexus_proxy_url}:8083"]
}
"@
$DaemonConfig | Out-File -Encoding Ascii ( New-Item -Path $env:ProgramData\docker\config\daemon.json -Force )

# R config
# $RconfigFilePathWindows = C:\Progra~1\R\4.1.2\etc\Rprofile.site
#Add-Content $RconfigFilePathWindows "local({`n    r <- getOption(`"repos`")`n    r[`"Nexus`"] <- `"${nexus_proxy_url}/repository/r-proxy/`"`n    options(repos = r)`n})"
# echo "local({`n    r <- getOption(`"repos`")`n    r[`"Nexus`"] <- `"${nexus_proxy_url}/repository/r-proxy/`"`n    options(repos = r)`n})" > $RconfigFilePathWindows
$RConfig = @"
local({
    r <- getOption("repos")
    r["Nexus"] <- "${nexus_proxy_url}/repository/r-proxy/"
    options(repos = r)
})
"@
$RConfig | Out-File -Encoding Ascii ( New-Item -Path $Env:C:\Software\R\etc\Rprofile.site -Force )
