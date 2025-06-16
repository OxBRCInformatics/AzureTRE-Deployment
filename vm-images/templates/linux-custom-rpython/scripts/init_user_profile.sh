#!/bin/bash
# This file should be put in /etc/profile.d directory to initialise user environment

# Add anaconda to PATH
export PATH=/opt/anaconda/bin:$PATH

# Set VSCode extensions root directory
export VSCODE_EXTENSIONS=/opt/vscode/extensions

# Add mssql-tools to PATH
export PATH="$PATH:/opt/mssql-tools18/bin"

# Add user to docker group (only once)
if ! groups $USER | grep -q docker; then
    sudo usermod -aG docker $USER
    echo "Added $USER to docker group. Please log out and back in for changes to take effect."
fi

# Setup xsession for XFCE (only once)
if [ ! -f ~/.xsession ]; then
    echo "Setting up xsession for XFCE"
    echo xfce4-session > ~/.xsession
    chmod +x ~/.xsession
fi

# Disable screensaver
if [ -f ~/.xscreensaver ]; then
    sed -i 's/random/blank/' ~/.xscreensaver
fi

# Function to install VSCode extensions safely
install_vscode_extensions() {
    if [ ! -f ~/.vscode_extensions_installed ] && command -v code >/dev/null 2>&1; then
        echo "Installing VSCode extensions for $USER..."

        # Create user-specific settings
        mkdir -p ~/.config/Code/User

        # Configure VS Code settings to reduce prompts
        cat > ~/.config/Code/User/settings.json << 'EOF'
{
    "telemetry.telemetryLevel": "off",
    "update.showReleaseNotes": false,
    "workbench.startupEditor": "none",
    "extensions.autoUpdate": false,
    "extensions.ignoreRecommendations": true,
    "workbench.enableExperiments": false,
    "workbench.settings.enableNaturalLanguageSearch": false
}
EOF

        # Install extensions with proper error handling
        local extensions=(
            "ms-python.python"
            "REditorSupport.r"
            "RDebugger.r-debugger"
            "ms-python.vscode-pylance"
            "ms-toolsai.vscode-ai-remote"
            "ms-vscode-remote.remote-containers"
            "janisdd.vscode-edit-csv"
        )

        for ext in "${extensions[@]}"; do
            echo "Installing extension: $ext"
            if ! timeout 120 code --install-extension "$ext" --force 2>/dev/null; then
                echo "Warning: Failed to install extension $ext"
            fi
        done

        # Mark as completed
        touch ~/.vscode_extensions_installed
        echo "VSCode extensions installation completed for $USER"
    fi
}

# Function to install Azure Data Studio extensions safely
install_ads_extensions() {
    if [ ! -f ~/.ads_extensions_installed ] && command -v azuredatastudio >/dev/null 2>&1; then
        echo "Installing Azure Data Studio extensions for $USER..."

        local ads_extensions=(
            "microsoft.azcli"
            "microsoft.azuredatastudio-mysql"
            "microsoft.admin-pack"
            "microsoft.arc"
            "microsoft.machine-learning"
            "microsoft.azuredatastudio-postgresql"
        )

        for ext in "${ads_extensions[@]}"; do
            echo "Installing ADS extension: $ext"
            if ! timeout 120 azuredatastudio --install-extension "$ext" 2>/dev/null; then
                echo "Warning: Failed to install ADS extension $ext"
            fi
        done

        # Mark as completed
        touch ~/.ads_extensions_installed
        echo "Azure Data Studio extensions installation completed for $USER"
    fi
}

# Only run extension installation if we have a display and it's an interactive session
if [ -n "${DISPLAY:-}" ] && [ -t 0 ] && [ "${-#*i}" != "$-" ]; then
    # Run extension installation in background after a delay
    (
        sleep 60  # Wait for desktop environment to fully initialize
        install_vscode_extensions
        install_ads_extensions
    ) &
fi

# Initialize conda for the user (only once)
if [ ! -f ~/.conda_initialized ] && [ -f /opt/anaconda/bin/conda ]; then
    echo "Initializing conda for $USER"
    /opt/anaconda/bin/conda init bash
    /opt/anaconda/bin/conda config --set auto_activate_base false
    touch ~/.conda_initialized
    echo "Conda initialized. Please restart your shell or run 'source ~/.bashrc'"
fi
