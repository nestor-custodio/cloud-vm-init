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




section "Setting up nvm (nodejs) ..."

	git clone -q https://github.com/creationix/nvm.git ~/.nvm
	cd ~/.nvm || exit
	git checkout -q "$( git describe --abbrev=0 --tags )"
	puts "source ~/.nvm/nvm.sh" >> ~/.zshrc

	zsh -ic 'nvm install stable'
	puts "stable" > ~/.nvmrc




section "Setting up Ruby + Rails + Heroku ..."

	# chruby v0.3.9 -- https://github.com/postmodern/chruby
	puts "\nInstalling: chruby ...\n"
		cd ~ || exit
		wget -q -O chruby-installer.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
		tar -xzvf chruby-installer.tar.gz > /dev/null && mv ./chruby-0.3.9 ./chruby-installer
		cd ~/chruby-installer || exit
		sudo make install > /dev/null
		sudo ./scripts/setup.sh
		cd ~ || exit
		rm -rf ~/chruby-installer*
		puts "source /usr/local/share/chruby/chruby.sh" >> ~/.zshrc
		puts "source /usr/local/share/chruby/auto.sh"   >> ~/.zshrc


	# ruby-install v0.7.0 -- https://github.com/postmodern/ruby-install
	puts "\nInstalling: ruby-install ...\n"
		cd ~ || exit
		wget -q -O ri-installer.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
		tar -xzvf ri-installer.tar.gz > /dev/null && mv ./ruby-install-0.7.0 ./ri-installer
		cd ~/ri-installer || exit
		sudo make install > /dev/null
		cd ~ || exit
		rm -rf ~/ri-installer*


	puts "\nPrepping for Ruby / Rails work ...\n"
		puts "ruby" > ~/.ruby-version
		sudo apt-get -qqy install libpq-dev  # We can't build the 'pg' gem without this.
		/snap/bin/heroku plugins:install heroku-accounts  # Simple juggling of Heroku credentials.




section "Cleaning apt caches ..."

	sudo apt-get -qy autoremove  # Note we're purposefully not fully quieting the autoremove.
	sudo apt-get -qqy autoclean




cd "$original_dir" || exit
