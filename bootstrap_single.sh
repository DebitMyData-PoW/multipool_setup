#!/usr/bin/env bash
#########################################################
# The YiiMP single server install (the DebitMyData pool), started from the menu: it downloads
# DebitMyData-PoW/multipool_yiimp_single to ~/multipool/yiimp_single and starts it.
# SINGLE_REF picks another branch or tag of it than master.
#
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use, and by DebitMyData for its pool.
#########################################################

SINGLE_REPO=https://github.com/DebitMyData-PoW/multipool_yiimp_single
SINGLE_REF="${SINGLE_REF:-master}"

if [ ! -d "$HOME/multipool/yiimp_single" ]; then
	echo "Downloading the YiiMP single server install ($SINGLE_REF)..."
	if ! git clone -q -b "$SINGLE_REF" "$SINGLE_REPO" "$HOME/multipool/yiimp_single" </dev/null; then
		echo "The download failed: is $SINGLE_REPO reachable from this server?"
		exit 1
	fi
fi

cd "$HOME/multipool/yiimp_single" || exit 1

# Bring it up to date (a branch moves on; a tag stays where it is).
sudo chown -R "$(id -un)" "$HOME/multipool/yiimp_single/.git/"
if ! { git fetch -q --tags origin &&
	git checkout -q "$SINGLE_REF" &&
	{ ! git show-ref -q --verify "refs/remotes/origin/$SINGLE_REF" ||
		git merge -q --ff-only "origin/$SINGLE_REF"; }; }; then
	echo "The update failed. Did you change something in $(pwd)?"
	exit 1
fi

cd "$HOME/multipool/yiimp_single" || exit 1
source start.sh
