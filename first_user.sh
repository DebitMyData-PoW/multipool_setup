#####################################################
# Run as root: makes the user account that the install runs as (with sudo), then asks for a
# reboot. Root's SSH keys are copied to it, so the same key logs in as that user.
#
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use, and by DebitMyData for its pool.
#####################################################

source /etc/functions.sh
cd ~/multipool/install || exit 1
clear
message_box "DebitMyData pool installer" \
"You are running the installer as root.
\n\nThe pool must not run as root: the installer now makes a user account for it. After a reboot, you log in as that user and type multipool to continue."

if [ -z "${yiimpadmin}" ]; then
	DEFAULT_yiimpadmin=yiimpadmin
	input_box "New Account Name" \
		"Please enter your desired user name.
\n\nUser Name:" \
		${DEFAULT_yiimpadmin} \
		yiimpadmin

	if [ -z "${yiimpadmin}" ]; then
		# user hit ESC/cancel
		exit
	fi
fi

if [ -z "${RootPassword}" ]; then
	DEFAULT_RootPassword=$(openssl rand -base64 18 | tr -d "=+/")
	input_box "User Password" \
		"Enter the new user's password, or keep this random one.
\n\nWrite it down or put it in your password manager: it cannot be copied from this screen.
\n\nUser password:" \
		${DEFAULT_RootPassword} \
		RootPassword

	if [ -z "${RootPassword}" ]; then
		# user hit ESC/cancel
		exit
	fi
fi

clear

dialog --title "Verify Your Responses" \
	--yesno "Please verify your answers before you continue:

New User Name : ${yiimpadmin}
New User Pass : ${RootPassword}" 8 60

# Get exit status
# 0 means user hit [yes] button.
# 1 means user hit [no] button.
# 255 means user hit [Esc] key.
response=$?
case $response in

	0)
		clear
		echo -e " Adding the new user...$COL_RESET"

		sudo adduser "${yiimpadmin}" --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
		echo -e "${RootPassword}\n${RootPassword}" | passwd "${yiimpadmin}"
		sudo usermod -aG sudo "${yiimpadmin}"

		# The same SSH key as root's logs in as the new user.
		if [ -s /root/.ssh/authorized_keys ]; then
			sudo install -d -m 700 -o "${yiimpadmin}" -g "${yiimpadmin}" "/home/${yiimpadmin}/.ssh"
			sudo install -m 600 -o "${yiimpadmin}" -g "${yiimpadmin}" /root/.ssh/authorized_keys \
				"/home/${yiimpadmin}/.ssh/authorized_keys"
		fi

		echo '# yiimp
# It needs passwordless sudo functionality.
'""''"${yiimpadmin}"''""' ALL=(ALL) NOPASSWD:ALL
' | sudo -E tee /etc/sudoers.d/${yiimpadmin} >/dev/null 2>&1
		sudo chmod 440 /etc/sudoers.d/${yiimpadmin}

		echo '
cd ~/multipool/install
bash start.sh
' | sudo -E tee /usr/bin/multipool >/dev/null 2>&1
		sudo chmod +x /usr/bin/multipool

		sudo cp -r ~/multipool /home/${yiimpadmin}/
		sudo chown -R "${yiimpadmin}:${yiimpadmin}" /home/${yiimpadmin}/multipool
		cd ~ || exit 1
		sudo rm -r multipool
		sudo setfacl -m u:${yiimpadmin}:rwx /home/${yiimpadmin}/multipool

		clear
		echo "The new user ${yiimpadmin} is ready."
		if [ -s /root/.ssh/authorized_keys ]; then
			echo "It logs in with the same SSH key as root."
		fi
		echo -e "$RED Reboot the server (type reboot), log in as ${yiimpadmin} and type$COL_RESET $GREEN multipool$COL_RESET $RED to continue the install.$COL_RESET"
		exit 0
		;;

	1)
		clear
		bash "$(basename "$0")" && exit
		;;

	255) ;;
esac
