#!/bin/bash

set -Eeuo pipefail
TEMP_OUTPUT="/tmp/linux_update.log"

# if we use package manager to update go-agent itself, it will just disconnect so we work around it
function run() {
	nohup "$@" > "$TEMP_OUTPUT" 2>&1 &
	PID=$!
	tail -f "$TEMP_OUTPUT" &
	TAIL_PID=$!
	wait "$PID"
	kill "$TAIL_PID"
	rm -f "$TEMP_OUTPUT"
}

function package_manager_update() {
	if command -v apt-get; then
		echo "Updating via APT..."
		
		export DEBIAN_FRONTEND=noninteractive
		export DEBIAN_PRIORITY=critical

		run dpkg --configure -a --force-all	
		run apt-get update -y
		run apt-get full-upgrade -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold"
		run apt-get autoremove -y
	fi

	if command -v pacman; then
		echo "Updating via pacman..."

		run pacman --sync --refresh --sysupgrade --noconfirm
	fi

	if command -v apk; then
		echo "Updating via apk..."

		run apk update
		run apk upgrade
	fi

	# note: some versions of OpenSUSE symlinks yum to zypper
	if command -v yum; then
		echo "Updating via yum..."

		run yum -y update
	fi

	if command -v zypper; then
		echo "Updating via zypper..."

		run zypper --non-interactive refresh
		run zypper --non-interactive update
	fi

	# how to use emerge unattended?
	#if command -v emerge; then
	#	echo "Updating via emerge..."
	#
	#	run emerge --sync
	#	run emerge --update --deep --with-bdeps=y @world
	#fi
}

package_manager_update

