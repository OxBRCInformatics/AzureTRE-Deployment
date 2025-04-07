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

# Define installation path
$installPath = "C:\Software\RStudio"

# Check if RStudio is installed
if (-not (Test-Path "$installPath\rstudio.exe")) {
    Write-Output "init_vm.ps1: Installing RStudio"

    # Define download URL (update as needed)
    $NEXUS_PROXY_URL = "YOUR_NEXUS_PROXY_URL"
    $rstudioUrl = "$NEXUS_PROXY_URL/repository/r-studio-download/electron/windows/rstudio-2023.12.1-402.exe"
    $installerPath = "$env:TEMP\rstudio-2023.12.1-402.exe"

    # Download the installer
    Invoke-WebRequest -Uri $rstudioUrl -OutFile $installerPath

    # Install RStudio to C:\Software\RStudio silently
    Start-Process -FilePath $installerPath -ArgumentList "/S /D=$installPath" -Wait

    Write-Output "RStudio installation complete."
} else {
    Write-Output "RStudio is already installed."
}

# Create a desktop shortcut for RStudio
$desktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"), "RStudio.lnk")
$rstudioPath = "$installPath\rstudio.exe"

if (Test-Path $rstudioPath) {
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($desktopPath)
    $shortcut.TargetPath = $rstudioPath
    $shortcut.WorkingDirectory = $installPath
    $shortcut.Save()

    Write-Output "Desktop shortcut for RStudio created."
} else {
    Write-Output "RStudio executable not found. Shortcut not created."
}

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

# Docker proxy config
$DaemonConfig = @"
{
"registry-mirrors": ["${nexus_proxy_url}:8083"]
}
"@
$DaemonConfig | Out-File -Encoding Ascii ( New-Item -Path $env:ProgramData\docker\config\daemon.json -Force )

# Sys.setenv(R_LIBCURL_SSL_REVOKE_BEST_EFFORT=TRUE) needed to allow https connection. Skips verification?

$RConfig = @"
local({
    r <- getOption("repos")
    r["Nexus"] <- "${nexus_proxy_url}/repository/r-proxy/"
    options(repos = r)
})

Sys.setenv(R_LIBCURL_SSL_REVOKE_BEST_EFFORT=TRUE)
"@
$RConfig | Out-File -Encoding Ascii ( New-Item -Path $Env:C:\Software\R\etc\Rprofile.site -Force )

# Update from upstream below, not required for our set up but leaving here in case needed in future. https://github.com/microsoft/AzureTRE/pull/4332
# $RBasePath = "$Env:ProgramFiles\R"
# $RVersions = Get-ChildItem -Path $RBasePath -Directory | Where-Object { $_.Name -like "R-*" }

# foreach ($RVersion in $RVersions) {
#     $ConfigPath = Join-Path -Path $RVersion.FullName -ChildPath "etc\Rprofile.site"
#     $RConfig | Out-File -Encoding Ascii (New-Item -Path $ConfigPath -Force)
# }
