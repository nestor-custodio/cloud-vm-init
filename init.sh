#! /bin/bash
# shellcheck disable=1117


sync_root="${HOME}/sync"




# Ensure we have sudo credentials handy.
sudo true


original_dir="$( pwd )"
cd ~ || exit


puts() { printf "%b\n" "$1"; }
divider() { printf "%${COLUMNS}s" | tr ' ' '-'; }
section() { printf "\n\n"; divider; printf "%s\n" "$1"; }




section "Installing packages ..."

	sudo snap install --classic aws-cli          2> /dev/null
	sudo snap install --classic google-cloud-sdk 2> /dev/null
	sudo snap install --classic heroku           2> /dev/null
	sudo snap install           jq               2> /dev/null
	sudo snap install           yq               2> /dev/null

	sudo apt-get -qq update
	sudo apt-get -qqy install apt-file   \
	                          byobu      \
	                          curl       \
	                          figlet     \
	                          gcc        \
	                          git        \
	                          make       \
	                          qrencode   \
	                          shellcheck \
	                          tree       \
	                          wget

	sudo apt-get -qqy install -f  # Resolve possible dependency issues.




section "Loading the apt-file database ..."

	# No need to wait on this, so we'll nohup it.
	sudo nohup apt-file update > /dev/null 2>&1 &




section "Configuring system behaviours ..."

	# Set sudo password appearance ...
	puts "Defaults pwfeedback" | sudo tee -a /etc/sudoers > /dev/null

	# Increase inotify watch limit ...
	sudo su -c '/usr/bin/echo -e "\n\nfs.inotify.max_user_watches = 524288\n\n" >> /etc/sysctl.conf'




section "Setting user shell ..."

	sudo chsh -s /bin/zsh "$( whoami )"




section "Prepping for Ruby / Rails work ..."

	sudo apt-get -qqy install libpq-dev  # We can't build the 'pg' gem without this.
	/snap/bin/heroku plugins:install heroku-accounts  # Simple juggling of Heroku credentials.




section "Cleaning apt caches ..."

	sudo apt-get -qy autoremove  # Note we're purposefully not fully quieting the autoremove.
	sudo apt-get -qqy autoclean




section "Setting up cross-instance config sync ..."

	mkdir -p "$sync_root"
	gsutil -m cp -P -r 'gs://vm-sync/*' "$sync_root" > /dev/null
	"${sync_root}/vm-sync" "$sync_root"




cd "$original_dir" || exit
