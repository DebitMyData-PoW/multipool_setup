#!/usr/bin/env bash
#########################################################
# The coin daemon builder. Not in the menu yet: DebitMyData-PoW/multipool_coin_builder comes
# once the builder is reworked for CMake (DMD Core 1.3 builds with CMake, the old builder
# with autotools). When it exists, add it back to menu.sh.
# COIN_REF picks another branch or tag of it than master.
#
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use, and by DebitMyData for its pool.
#########################################################

COIN_REPO=https://github.com/DebitMyData-PoW/multipool_coin_builder
COIN_REF="${COIN_REF:-master}"

if [ ! -d "$HOME/multipool/daemon_builder" ]; then
	echo "Downloading the coin daemon builder ($COIN_REF)..."
	if ! git clone -q -b "$COIN_REF" "$COIN_REPO" "$HOME/multipool/daemon_builder" </dev/null; then
		echo "The download failed: is $COIN_REPO reachable from this server?"
		exit 1
	fi
fi

cd "$HOME/multipool/daemon_builder" || exit 1

# Bring it up to date (a branch moves on; a tag stays where it is).
sudo chown -R "$(id -un)" "$HOME/multipool/daemon_builder/.git/"
if ! { git fetch -q --tags origin &&
	git checkout -q "$COIN_REF" &&
	{ ! git show-ref -q --verify "refs/remotes/origin/$COIN_REF" ||
		git merge -q --ff-only "origin/$COIN_REF"; }; }; then
	echo "The update failed. Did you change something in $(pwd)?"
	exit 1
fi

cd "$HOME/multipool/daemon_builder" || exit 1
source install.sh
