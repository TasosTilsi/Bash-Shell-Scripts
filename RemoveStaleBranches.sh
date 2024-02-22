#!/bin/bash

echo "   ___                         ______       __    ___                    __         ";
echo "  / _ \___ __ _  ___ _  _____ / __/ /____ _/ /__ / _ )_______ ____  ____/ /  ___ ___";
echo " / , _/ -_)  ' \/ _ \ |/ / -_)\ \/ __/ _ \`/ / -_) _  / __/ _ \`/ _ \/ __/ _ \/ -_|_-<";
echo "/_/|_|\__/_/_/_/\___/___/\__/___/\__/\_,_/_/\__/____/_/  \_,_/_//_/\__/_//_/\__/___/";
echo "                                                                                    ";

# Define the function to remove stale branches for a single Git repository
function remove_stale_branches {
    # Fetch all the remote branches and remove deleted ones
    git fetch --prune

    # Get a list of local branches that are not in the remote
    local_branches=$(git branch -vv | grep ': gone]' | awk '{print $1}')

    # Loop through each local branch and delete it
    for branch in $local_branches; do
        if [[ "$(git branch -r | grep -c ${branch})" == "0" ]]; then
            echo "Deleting local branch ${branch}"
            git branch -D ${branch}
        fi
    done
}

# Default the root directory to the current working directory
ROOT_DIR=$(pwd)

# Check if the root directory is set by the user
if [[ ! -z $1 ]]; then
    ROOT_DIR=$1
fi

# Display usage instructions when invoked with -h or --help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [root_directory]"
    echo "  - root_directory: Optional. The directory containing Git repositories (default: current working directory)"
    exit 0
fi

# Loop around all the directories in the root directory that contain a .git folder
for dir in $(find $ROOT_DIR -type d -name .git | awk -F/.git '{print $1}'); do
    echo "Processing git repository in $dir"
    cd $dir
    # Call the function to remove stale branches in the repository
    remove_stale_branches
    cd ..
done
