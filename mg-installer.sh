#!/bin/bash

NC='\033[0m' # No Color
RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[1;32m' # Boldie Light Green
BLUE='\033[1;34m' # Boldie Light Blue
YELLOW='\033[1;33m' # Boldie Yellow

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
	apt-get install -y $@
	echo -e "${GREEN}- Installed. ($@)${NC}"
}

# Functions for installing packages

install_utilities() {
	echo -e "${BLUE}Installing utilities:${NC}"
	check_if_installed "filezilla"
        RESPONSE=$?
        if [ "$RESPONSE" -ne "1" ]; then
		install_packages "terminator" "filezilla"
	fi
}

install_docker() {
	echo -e "${BLUE}Installing Docker CE:${NC}"
	check_if_installed "docker-ce"
	RESPONSE=$?
	if [ "$RESPONSE" -ne "1" ]; then
		apt-get remove docker docker-engine docker.io -y
		apt-get install -y apt-transport-https ca-certificates curl software-properties-common
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
		apt-key fingerprint 0EBFCD88
		echo "deb [arch=$(uname -m)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
		install_packages "docker-ce"
	fi
	echo -e "${BLUE}Installing Docker Compose:${NC}"
	check_if_installed "docker-compose"
	RESPONSE=$?
	if [ "$RESPONSE" -ne "1" ]; then
		curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
		chmod +x /usr/local/bin/docker-compose
		echo -e "${GREEN}$(docker-compose --version)"
	fi
}

install_google_chrome() {
	echo -e "${BLUE}Installing Google Chrome:${NC}"
	check_if_installed "google-chrome-stable"
	RESPONSE=$?
	if [ "$RESPONSE" -ne "1" ]; then
		echo "deb [arch=$(uname -m)] http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google-chrome.list
		wget https://dl.google.com/linux/linux_signing_key.pub
		apt-key add linux_signing_key.pub
		install_packages "google-chrome-stable"
		rm linux_signing_key.pub
	fi
}

install_git() {
	echo -e "${BLUE}Installing Git:${NC}"
	check_if_installed "git"
	RESPONSE=$?
	if [ "$RESPONSE" -ne "1" ]; then
		install_packages "git"
	fi
	git config --global user.email "marcogonzalo@gmail.com"
	git config --global user.name "@MarcoGonzalo"
	echo -e "${YELLOW}Remember to set your SSH keys!${NC}"
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
install_google_chrome
install_sublime_text
install_docker
install_git

exit 0
