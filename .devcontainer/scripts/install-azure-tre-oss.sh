#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
# Uncomment this line to see each command for debugging (careful: this will show secrets!)
# set -o xtrace

upstream_repo="$1"
upstream_repo_version="$2"
upstream_home="$3"
github_token="${4:-}"

# Clone or update the repository
if [[ -d "$upstream_home/.git" ]]; then
    echo "Repository already exists. Checking for updates..."
    git -C "$upstream_home" fetch origin

    # Check if the version is a branch or a tag
    if git -C "$upstream_home" show-ref --verify --quiet "refs/heads/$upstream_repo_version"; then
        echo "Version is a branch. Pulling latest changes..."
        git -C "$upstream_home" checkout "$upstream_repo_version"
        git -C "$upstream_home" pull origin "$upstream_repo_version"
    elif git -C "$upstream_home" show-ref --verify --quiet "refs/tags/$upstream_repo_version"; then
        echo "Version is a tag. Checking out the tag..."
        git -C "$upstream_home" checkout "tags/$upstream_repo_version"
    else
        echo "Error: Version '$upstream_repo_version' is neither a branch nor a tag."
        exit 1
    fi
else
    echo "Cloning repository..."
    if [[ -n "$github_token" ]]; then
        git clone "https://${github_token}@github.com/${upstream_repo}.git" "$upstream_home"
    else
        git clone "https://github.com/${upstream_repo}.git" "$upstream_home"
    fi

    cd "$upstream_home"

    # Check if the version is a branch or a tag
    if git show-ref --verify --quiet "refs/heads/$upstream_repo_version"; then
        echo "Version is a branch. Checking out the branch..."
        git checkout "$upstream_repo_version"
    elif git show-ref --verify --quiet "refs/tags/$upstream_repo_version"; then
        echo "Version is a tag. Checking out the tag..."
        git checkout "tags/$upstream_repo_version"
    else
        echo "Error: Version '$upstream_repo_version' is neither a branch nor a tag."
        exit 1
    fi
fi

# Save repository metadata
echo "${upstream_repo}" > "$upstream_home/repository.txt"
echo "${upstream_repo_version}" > "$upstream_home/version.txt"
