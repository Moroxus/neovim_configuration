#!/bin/bash
{
	/usr/bin/env ruby --version
} &> /dev/null

if [ $? -eq 0 ] 
then
	echo "Ruby found: `which ruby`"
else
	echo "Installing ruby"
	sudo pacman -S ruby
fi

./install_and_configure_neovim.sh $@

EXIT_STATUS=$?

exit $EXIT_STATUS
