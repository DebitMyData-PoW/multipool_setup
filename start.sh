#!/usr/bin/env bash
#####################################################
# The installer's entry point (bootstrap.sh starts it, and so does the "multipool" command).
# As root, it makes the user account the install runs as, then stops: log in as that user and
# type multipool. As that user, it asks the first questions and shows the menu.
#
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use, and by DebitMyData for its pool.
#####################################################

cd "$HOME/multipool/install" || exit 1

source functions.sh # load our functions
# copy functions to /etc
sudo cp -r functions.sh /etc/

# Check the system: Ubuntu 24.04 on x86_64, with enough memory (and swap if needed).
# If not, this shows an error and exits.
source preflight.sh

# Ensure Python reads/writes files in UTF-8.
if ! locale -a | grep en_US.utf8 > /dev/null; then
	hide_output sudo locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# So that line drawing characters show correctly in PuTTY on Windows.
export NCURSES_NO_UTF8_ACS=1

# Recall the last settings used if we're running this a second time.
if [ -f /etc/multipool.conf ]; then
	# Load the old .conf file to get existing configuration options loaded
	# into variables with a DEFAULT_ prefix.
	sed s/^/DEFAULT_/ /etc/multipool.conf > /tmp/multipool.prev.conf
	source /tmp/multipool.prev.conf
	rm -f /tmp/multipool.prev.conf
else
	FIRST_TIME_SETUP=1
fi

echo -e " Installing the packages the installer needs...$COL_RESET"
apt_get_quiet update
apt_get_quiet install dialog python3 acl nano git curl

# As root: make the user account the install runs as, then stop.
if [[ $EUID -eq 0 ]]; then
	source first_user.sh
	exit
fi

# Ask the user the initial questions
source pre_setup.sh

# Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist.
if ! id -u "$STORAGE_USER" >/dev/null 2>&1; then
	sudo useradd -m "$STORAGE_USER"
fi
if [ ! -d "$STORAGE_ROOT" ]; then
	sudo mkdir -p "$STORAGE_ROOT"
fi

# Save the global options in /etc/multipool.conf so that standalone
# tools know where to look for data.
echo 'STORAGE_USER='"${STORAGE_USER}"'
STORAGE_ROOT='"${STORAGE_ROOT}"'
PUBLIC_IP='"${PUBLIC_IP}"'
PUBLIC_IPV6='"${PUBLIC_IPV6}"'
PRIVATE_IP='"${PRIVATE_IP}"'' | sudo -E tee /etc/multipool.conf >/dev/null 2>&1

# Start service configuration.
source menu.sh

# Give fail2ban another restart. The log files may not all have been present when
# fail2ban was first configured, but they should exist now.
restart_service fail2ban

# Done.
echo
echo "-----------------------------------------------"
echo
echo "The DebitMyData pool installer has finished."
echo
echo "To run it again at any time, type: multipool"
cd ~ || exit
