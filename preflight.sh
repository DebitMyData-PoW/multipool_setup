#####################################################
# Checks the server before anything is installed: Ubuntu 24.04, x86_64, enough memory, and
# swap on a small server. Sourced by start.sh: exits if the server does not fit.
#
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use, and by DebitMyData for its pool.
#####################################################

OS_RELEASE="$(. /etc/os-release && echo "$ID $VERSION_ID")"
if [ "$OS_RELEASE" != "ubuntu 24.04" ]; then
	echo "The DebitMyData pool installer needs Ubuntu 24.04. This server runs:"
	echo
	(. /etc/os-release && echo "$PRETTY_NAME")
	echo
	echo "Install it on a fresh Ubuntu 24.04 server."
	exit 1
fi

ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
	if [ -z "$ARM" ]; then
		echo "The DebitMyData pool installer only supports x86_64 (64-bit Intel or AMD), not ARM or a 32-bit system."
		echo "This server is $ARCHITECTURE."
		exit 1
	fi
fi

# Memory, in kB.
TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}')
if [ "$TOTAL_PHYSICAL_MEM" -lt 1000000 ]; then
	if [ ! -d /vagrant ]; then
		echo "The pool server needs more memory (RAM): at least 1 GB, 4 GB or more recommended."
		echo "This server has $((TOTAL_PHYSICAL_MEM / 1024)) MB."
		exit 1
	fi
fi
if [ "$TOTAL_PHYSICAL_MEM" -lt 4000000 ]; then
	echo "WARNING: this server has less than 4 GB of memory. The pool may run slowly under load."
fi

# Swap: on a server with less than 4 GB of memory and none yet, a 4 GB swap file, so that the
# builds (the stratum, a coin daemon) do not run out of memory.
echo "Checking if swap space is needed..."
SWAP_MOUNTED=$(tail -n+2 /proc/swaps)
SWAP_IN_FSTAB=$(grep "swap" /etc/fstab)
ROOT_IS_BTRFS=$(grep "\/ .*btrfs" /proc/mounts)
AVAILABLE_DISK_SPACE=$(df / --output=avail | tail -n 1)
if
	[ -z "$SWAP_MOUNTED" ] &&
	[ -z "$SWAP_IN_FSTAB" ] &&
	[ ! -e /swapfile ] &&
	[ -z "$ROOT_IS_BTRFS" ] &&
	[ "$TOTAL_PHYSICAL_MEM" -lt 4000000 ] &&
	[ "$AVAILABLE_DISK_SPACE" -gt 10485760 ]
then
	echo "Adding a 4 GB swap file..."
	sudo fallocate -l 4G /swapfile
	if [ -e /swapfile ]; then
		sudo chmod 600 /swapfile
		hide_output sudo mkswap /swapfile
		sudo swapon /swapfile
		echo "vm.swappiness=10" | sudo tee /etc/sysctl.d/60-swappiness.conf >/dev/null
		sudo sysctl -q -w vm.swappiness=10 || true
	fi

	# Activate it on boot too
	if swapon -s | grep -q "\/swapfile"; then
		echo "/swapfile  none swap sw 0  0" | sudo tee -a /etc/fstab >/dev/null
	else
		echo "ERROR: the swap file could not be added"
	fi
fi

# Set STORAGE_USER and STORAGE_ROOT to default values (crypto-data and /home/crypto-data), unless
# we've already got those values from a previous run. The pool's code expects these.
if [ -z "$STORAGE_USER" ]; then
	STORAGE_USER=$([[ -z "$DEFAULT_STORAGE_USER" ]] && echo "crypto-data" || echo "$DEFAULT_STORAGE_USER")
fi
if [ -z "$STORAGE_ROOT" ]; then
	STORAGE_ROOT=$([[ -z "$DEFAULT_STORAGE_ROOT" ]] && echo "/home/$STORAGE_USER" || echo "$DEFAULT_STORAGE_ROOT")
fi
