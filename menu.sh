#####################################################
# The installer's menu: the YiiMP single server (the DebitMyData pool) only.
# Source code https://github.com/end222/pacmenu
# Updated by cryptopool.builders for crypto use, and by DebitMyData for its pool.
#####################################################

source /etc/functions.sh

RESULT=$(dialog --stdout --nocancel --default-item 1 --title "DebitMyData pool installer" \
	--menu "Choose one" -1 60 4 \
	1 "YiiMP single server (the DebitMyData pool)" \
	2 "Exit")

case "$RESULT" in
	1)
		clear
		cd "$HOME/multipool/install" || exit 1
		source bootstrap_single.sh
		;;
	*)
		clear
		exit
		;;
esac
