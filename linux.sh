#!/bin/bash

set -Eeuo pipefail

function package_manager_update() {
	if command -v apt-get; then
		echo "Updating via APT..."
		
		export DEBIAN_FRONTEND=noninteractive
		export DEBIAN_PRIORITY=critical
	
		apt-get update -y
		apt-get full-upgrade -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold"
		apt-get autoremove -y
	fi

	if command -v pacman; then
		echo "Updating via pacman..."

		pacman --sync --refresh --sysupgrade --noconfirm
	fi

	if command -v apk; then
		echo "Updating via apk..."

		apk update
		apk upgrade
	fi

	# note: some versions of OpenSUSE symlinks yum to zypper
	if command -v yum; then
		echo "Updating via yum..."

		yum -y update
	fi

	if command -v zypper; then
		echo "Updating via zypper..."

		zypper --non-interactive refresh
		zypper --non-interactive update
	fi

	# how to use emerge unattended?
	#if command -v emerge; then
	#	echo "Updating via emerge..."
	#
	#	emerge --sync
	#	emerge --update --deep --with-bdeps=y @world
	#fi
}

package_manager_update

