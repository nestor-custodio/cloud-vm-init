#! /bin/bash
# shellcheck disable=1117


# Ensure we have sudo credentials handy.
sudo true


original_dir="$( pwd )"
cd ~ || exit


puts() { printf "%b\n" "$1"; }
divider() { printf "%${COLUMNS}s" | tr ' ' '-'; }
section() { printf "\n\n"; divider; printf "%s\n" "$1"; }




section "Installing packages ..."

	sudo snap install --classic aws-cli
	sudo snap install --classic google-cloud-sdk
	sudo snap install --classic heroku
	sudo snap install           jq
	sudo snap install           yq

	sudo apt-get -qq update
	sudo apt-get -qqy install \
	                          \
	    zsh                   \
	    tmux                  \
	    byobu                 \
	                          \
	    apt-file              \
	    curl                  \
	    figlet                \
	    git                   \
	    make                  \
	    shellcheck            \
	    tree                  \
	    wget                  \
	                          \
	    mysql-client          \
	    postgresql-client     \
	    redis-tools           \
	    sqlite

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




cd "$original_dir" || exit
