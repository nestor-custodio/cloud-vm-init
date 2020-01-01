#! /bin/bash
# shellcheck disable=1117,2164


# Ensure we have sudo credentials handy.
sudo true
pushd ~


section() { printf "\n\n\n%s\n" "$1"; }
puts() { printf "%s\n" "$1"; }




section "Installing packages ..."

	sudo snap install --classic aws-cli heroku

	sudo apt udpate
	sudo apt -y install   \
	                      \
	    zsh               \
	    tmux              \
	    byobu             \
	                      \
	    apt-file          \
	    curl              \
	    git               \
	    make              \
	    shellcheck        \
	    tree              \
	    wget              \
	                      \
	    mysql-client      \
	    postgresql-client \
	    redis-tools       \
	    sqlite

	sudo apt -y install -f  # Resolve possible dependency issues.




section "Loading the apt-file database ..."

	sudo apt-file update > /dev/null




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


	puts "\nBuilding latest ruby binaries ...\n"
		zsh -ic 'ruby-install --latest ruby'
		puts "ruby" > ~/.ruby-version


	puts "\nSetting up Rails gem ...\n"
		zsh -ic 'gem install rails'
		sudo apt -y install libpq-dev  # We can't build the 'pg' gem without this.


	heroku plugins:install heroku-accounts  # Simple juggling of Heroku credentials.




section "Cleaning apt caches ..."

	sudo apt -y autoremove
	sudo apt -y autoclean




puts "DONE"
popd