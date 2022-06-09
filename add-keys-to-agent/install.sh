#!/bin/sh

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

# Must be run as sudo to install script to /usr/local/bin
if [ "$USER" != 'root' ]; then
    echo "${RED}MUST be run with sudo${NC}"
    exit
fi

# Because this install is being run as 'root', get home and shell
# for the user that invoked sudo 
home="/home/$(logname)"
shell=$(su - "$(logname)" -c env | grep 'SHELL' | sed 's/SHELL\=//')

# Install locations for script and icon
install_location="/usr/local/bin/add-keys.sh"


# Compare files installed and to be installed
# This way we only install 'new' versions of scripts etc
hash_compare() {
    # get JUST the hashes
    installed_hash=$(md5sum "$1" | sed 's/  .*//')
    current_hash=$(md5sum "$2" | sed 's/  .*//')

    if [ "$installed_hash" = "$current_hash" ]; then
        return 1
    else
        return 0
    fi
}

echo "${GREEN}Installing add-keys${NC}"
echo ""

# If script is not installed or new version available, install it
if [ ! -f $install_location ] || hash_compare "$(pwd)/add-keys.sh" "$install_location"; then
    if ! cp "$(pwd)/add-keys.sh" "$install_location"; then
        exit
    fi
fi 

# Set config directory, to allow for blacklist to be written
config_dir="$home/.add-keys"

if [ ! -d "$config_dir" ] && [ $? ]; then
    mkdir "$config_dir"
    chown "$(logname)":"$(logname)" "$config_dir"
fi

# Allow runner to be added to shell rc
add_to_rc(){

    shell_configured=$(grep 'add-keys.sh' "$home/${rc}")

    if [ ! "$shell_configured" ]; then

        echo "add-keys.sh" >> "$home/${rc}"
        echo ""
        echo "${YELLOW}Reload your shell after install complete"
        echo "Alternatively source your shell config  with \`source $home/${rc}\`${NC}"
    else
        echo "${YELLOW}$home/${rc} already contains 'add-keys.sh'${NC}"
    fi
}

# Test shells for know shell to get correct rc, or echo 'manual mode' message
if [ "$shell" = "/usr/bin/zsh" ]; then
    rc=".zshrc"
    add_to_rc
elif [ "$shell" = "/bin/bash" ]; then
    rc=".bashrc"
    add_to_rc
else
    echo "${YELLOW}User not using approved shell"
    echo "Add 'add-keys.sh' to your shells start configuration and source it manually${NC}"
fi

echo ""
echo "${GREEN}add-keys has been installed successfully${NC}"
echo "${GREEN}Blacklist keyfiles from being automatically added to your agent${NC}"
echo "${GREEN}by adding line separated filepaths to $home/.add-keys/blacklist${NC}"


