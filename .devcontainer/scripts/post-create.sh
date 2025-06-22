#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
# Uncomment this line to see each command for debugging (careful: this will show secrets!)
# set -o xtrace

# show the AzureTRE OSS folder inside the workspace one
rm -fr AzureTRE || true
ln -s "${AZURETRE_HOME}" AzureTRE

cp ~/AzureTRE/config.sample.yaml .

# docker socket fixup
sudo bash AzureTRE/devops/scripts/set_docker_sock_permission.sh

# Re-run the install-azure-tre-oss.sh script
echo "Re-running install-azure-tre-oss.sh..."
bash /tmp/install-azure-tre-oss.sh "${UPSTREAM_REPO}" "${UPSTREAM_REPO_VERSION}" "${AZURETRE_HOME}" "${GITHUB_TOKEN}"
