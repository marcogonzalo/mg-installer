#!/bin/bash

# Detect the architecture
if [[ "$(uname -m)" = "x86_64" ]]; then
	ARCHITECTURE="x64"
else
	ARCHITECTURE="x32"
fi

NC='\033[0m' # No Color
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[1;32m' # Light Green
BLUE='\033[1;34m' # Light Blue

check_if_installed() {
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1 | grep "install ok installed")
	if [ "" == "$PKG_OK" ]; then
		return 2
	fi
	echo -e "${GREEN}- Already installed.${NC}"
	return 1
}

install_packages() {
	apt-get update
	apt-get install $@ -y
	echo -e "${GREEN}- Installed.${NC}"
}

# Functions for installing packages

install_utilities() {
	echo -e "${BLUE}Installing utilities:${NC}"
	install_packages "terminator"
}

install_google_chrome() {
	echo -e "${BLUE}Installing Google Chrome:${NC}"
	check_if_installed "google-chrome-stable"
	RESPONSE=$?
	if [ "$RESPONSE" -ne "1" ]; then
		echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
		wget https://dl.google.com/linux/linux_signing_key.pub
		apt-key add linux_signing_key.pub
		install_packages "google-chrome-stable"
	fi
}

install_git() {
	echo -e "${BLUE}Installing Git:${NC}"
	check_if_installed "git"
	RESPONSE=$?
	if [ "$RESPONSE" -ne "1" ]; then
		install_packages "git"
	fi
}

install_sublime_text() {
	echo -e "${BLUE}Installing Sublime Text:${NC}"
	check_if_installed "sublime-text"
	RESPONSE=$?
	if [ "$RESPONSE" -ne "1" ]; then
		wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add -
		apt-get install apt-transport-https -y
		echo "deb https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list
		install_packages "sublime-text"
	fi
}

echo -e "<--- ${ORANGE}Starting MGInstaller${NC} --->"
echo -e "${BLUE}Updating and upgrading installed packages${NC}"
apt-get update
apt-get upgrade -y
install_utilities
install_git
install_google_chrome
install_sublime_text

exit 0
