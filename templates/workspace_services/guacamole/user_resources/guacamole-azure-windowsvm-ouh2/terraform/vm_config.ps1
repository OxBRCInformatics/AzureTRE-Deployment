$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# NOTE: The following are pre-configured in the VM image and are NOT repeated here:
#   - pip          (C:\ProgramData\pip\pip.ini)        → Nexus PyPI proxy
#   - conda        (system .condarc)                   → Nexus conda proxy
#   - R            (Rprofile.site, wininet method)     → Nexus R proxy
#   - Anaconda     PATH set at Machine scope           → C:\tools\Anaconda3
#   - Docker       not installed (WSL2/Hyper-V incompatible with Windows Server 2019)
# ---------------------------------------------------------------------------

# Remove Azure provisioning artefact
Remove-Item -LiteralPath "C:\AzureData" -Force -Recurse -ErrorAction SilentlyContinue

# Shared storage — write a startup script that maps the share at logon
if ( ${SharedStorageAccess} -eq 1 ) {
    $Command = "net use z: \\${StorageAccountFileHost}\${FileShareName} /u:AZURE\${StorageAccountName} ${StorageAccountKey}"
    $Command | Out-File "C:\ProgramData\Start Menu\Programs\StartUp\attach_storage.cmd" -Encoding Ascii
}