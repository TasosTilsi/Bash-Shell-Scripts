#!/bin/bash


echo "  _____      _                    _____                     ";
echo " |  __ \    | |                  |  __ \                    ";
echo " | |__) |___| |__   __ _ ___  ___| |__) |_____   _____ _ __ ";
echo " |  _  // _ \ '_ \ / _\` / __|/ _ \  _  // _ \ \ / / _ \ '__|";
echo " | | \ \  __/ |_) | (_| \__ \  __/ | \ \ (_) \ V /  __/ |   ";
echo " |_|  \_\___|_.__/ \__,_|___/\___|_|  \_\___/ \_/ \___|_|   ";
echo "                                                            ";
echo "                                                            ";

# Explanation:
# This script provides functionality for rebasing a current branch onto a specified target branch.
# It includes the following features:
# - A visually appealing header using ASCII art.
# - A help message that explains the available options:
#     - `-p, --parent`: Specify the parent branch (default: rest-assured).
#     - `-c, --current`: Specify the current branch (default: gets the current checked out branch).
#     - `-h, --help`: Display this help message.
# - Default values for the parent branch and the current branch.
# - Parsing of command-line options using a `while` loop and a `case` statement.
# - A check for Git conflicts using the `check_conflicts` function.
# - A `perform_rebase` function that displays a message about rebasing the current branch onto the specified target branch.

# Function to display usage information
display_help() {
    echo "Usage: $0 [-p|--parent <parent_branch>] [-c|--current <current_branch>] [-h|--help]"
    echo "  -p, --parent   Specify the parent branch (default: rest-assured)"
    echo "  -c, --current  Specify the current branch (default: gets the current checked out branch)"
    echo "  -h, --help     Display this help message"
    exit 1
}

# Default values
parent_branch="rest-assured"
current_branch=$(git symbolic-ref --short HEAD)

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--parent)
            parent_branch="$2"
            shift 2
            ;;
        -c|--current)
            current_branch="$2"
            shift 2
            ;;
        -h|--help)
            display_help
            ;;
        *)
            echo "Invalid option: $1"
            display_help
            ;;
    esac
done

# Log separator
log_separator="=============================="

# Function to check for conflicts
check_conflicts() {
    if git diff --name-only --diff-filter=U | grep -q .; then
        echo "Conflicts detected. Resolve conflicts and re-run the script."
        exit 1
    fi
}

# Rebase function
perform_rebase() {
    local target_branch="$1"
    echo "Rebasing $current_branch onto $target_branch"
    git rebase "$target_branch"
    check_conflicts
    echo "$log_separator"
}

# Main script
echo "Checking out parent branch: $parent_branch"
git checkout "$parent_branch"
echo "$log_separator"

echo "Pulling latest changes for $parent_branch"
git pull
echo "$log_separator"

echo "Checking out current branch: $current_branch"
git checkout "$current_branch"
echo "$log_separator"

perform_rebase "$parent_branch"

echo "Forcing push to remote"
git push -f
echo "$log_separator"

echo "Checking out parent branch again"
git checkout "$parent_branch"
echo "$log_separator"

perform_rebase "$current_branch"

echo "Forcing push to remote"
git push -f
echo "$log_separator"

echo "Switching back to current branch: $current_branch"
git checkout "$current_branch"
echo "$log_separator"

echo "Script execution completed successfully!"
