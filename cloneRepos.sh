#!/bin/bash

# Function to display script usage and explanation
show_help() {
    echo "Usage: ./clone_repos.sh [OPTIONS] <GITHUB_USERNAME> [REPO_FOLDER]"
    echo "Clone GitHub repositories of a user from a specific folder locally."
    echo
    echo "Options:"
    echo "  -h, --help   Display this help message and exit."
    echo
    echo "Explanation:"
    echo "This script takes a GitHub username and an optional repository folder as parameters."
    echo "If a repository folder is provided, it retrieves the list of repositories from that folder."
    echo "If no repository folder is provided, it retrieves the list of all repositories for the user."
    echo "Next, it clones each repository locally using the git clone command."
    echo
    echo "Examples:"
    echo "  ./clone_repos.sh johnsmith"
    echo "  ./clone_repos.sh johnsmith my-folder"
    echo
    echo "Note:"
    echo "If the repository folder name is provided, only repositories whose names start with the folder name will be cloned."
    echo "For example, if the repository folder is 'my-folder', repositories 'my-folder-app', 'my-folder-utils', etc., will be cloned."
    echo
}

# Check if the help option is provided
if [[ $1 == "-h" || $1 == "--help" ]]; then
    show_help
    exit 0
fi

# Check if the GitHub username is provided
if [ -z "$1" ]; then
    echo "GitHub username is missing."
    echo "Usage: ./clone_repos.sh [OPTIONS] <GITHUB_USERNAME> [REPO_FOLDER]"
    exit 1
fi

# GitHub API URL
api_url="https://api.github.com/users/$1/repos"

# Check if the repository folder is provided
if [ -n "$2" ]; then
    api_url+="?type=owner&sort=updated&direction=desc&per_page=100"
    repos=$(curl -s "$api_url" | jq -r --arg REPO_FOLDER "$2" '.[] | select(.name | startswith($REPO_FOLDER)) | .ssh_url')
else
    repos=$(curl -s "$api_url" | jq -r '.[].ssh_url')
fi

# Check if any repositories are found
if [ -z "$repos" ]; then
    if [ -n "$2" ]; then
        echo "No repositories found in folder '$2' for user '$1'."
    else
        echo "No repositories found for user '$1'."
    fi
    exit 1
fi

# Clone each repository locally
for repo in $repos; do
    repo_name=$(basename "$repo" .git)
    
    # Check if the repository already exists locally
    if [ -d "$repo_name" ]; then
        echo "Repository $repo_name already exists locally."
    else
        # Clone the repository using SSH
        git clone "$repo"
        echo "Repository $repo_name cloned successfully."
    fi
done
