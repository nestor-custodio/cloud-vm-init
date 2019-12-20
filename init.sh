#! /bin/bash
# shellcheck disable=1117,2164


# Ensure we have sudo credentials handy.
sudo true
pushd ~


puts() { printf "%b\n" "$1"; }
divider() { printf "%${COLUMNS}s" | tr ' ' '-'; }
section() { printf "\n\n"; divider; printf "%s\n" "$1"; }




section "Installing packages ..."

	sudo snap install --classic aws-cli
	sudo snap install --classic google-cloud-sdk
	sudo snap install --classic heroku

	sudo apt-get update
	sudo apt-get -y install \
	                        \
	    zsh                 \
	    tmux                \
	    byobu               \
	                        \
	    apt-file            \
	    curl                \
	    figlet              \
	    git                 \
	    make                \
	    shellcheck          \
	    tree                \
	    wget                \
	                        \
	    mysql-client        \
	    postgresql-client   \
	    redis-tools         \
	    sqlite

	sudo apt-get -qy install -f  # Resolve possible dependency issues.




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

	git clone https://github.com/creationix/nvm.git ~/.nvm
	cd ~/.nvm
	git checkout "$( git describe --abbrev=0 --tags )"
	puts "source ~/.nvm/nvm.sh" >> ~/.zshrc

	zsh -ic 'nvm install stable'
	puts "stable" > ~/.nvmrc




section "Setting up Ruby + Rails + Heroku ..."

	# chruby v0.3.9 -- https://github.com/postmodern/chruby
	puts "\nInstalling: chruby ...\n"
		cd ~
		wget -q -O chruby-installer.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
		tar -xzvf chruby-installer.tar.gz > /dev/null && mv ./chruby-0.3.9 ./chruby-installer
		cd ~/chruby-installer
		sudo make install > /dev/null
		sudo ./scripts/setup.sh
		cd ~
		rm -rf ~/chruby-installer*
		puts "source /usr/local/share/chruby/chruby.sh" >> ~/.zshrc
		puts "source /usr/local/share/chruby/auto.sh"   >> ~/.zshrc


	# ruby-install v0.7.0 -- https://github.com/postmodern/ruby-install
	puts "\nInstalling: ruby-install ...\n"
		cd ~
		wget -q -O ri-installer.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
		tar -xzvf ri-installer.tar.gz > /dev/null && mv ./ruby-install-0.7.0 ./ri-installer
		cd ~/ri-installer
		sudo make install > /dev/null
		cd ~
		rm -rf ~/ri-installer*


	puts "\nPrepping for Ruby / Rails work ...\n"
		puts "ruby" > ~/.ruby-version
		sudo apt-get -y install libpq-dev  # We can't build the 'pg' gem without this.
		/snap/bin/heroku plugins:install heroku-accounts  # Simple juggling of Heroku credentials.




section "Cleaning apt caches ..."

	sudo apt-get -y autoremove
	sudo apt-get -y autoclean




puts "DONE"
popd
