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
$INSTALL_DIRECTORY="C:\Software"
$VSCODE_INSTALL_PATH="$INSTALL_DIRECTORY\VSCode"
$VSCODE_EXTENSION_PATH="$VSCODE_INSTALL_PATH\extensions"
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
