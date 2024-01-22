#!/bin/env bash

# if [ $# -eq 0 ]; then # Для работы скрипта необходим входной параметр.
# 	echo "Вызовите сценарий с параметрами: keyrings.sh sources_dir destination_dir "
# fi

sources_keyrings_dir=$1
destination_keyrings_dir=$2

# apt_dir=/etc/apt
# sources_dir="$apt_dir"/sources.list.d
# keyrings_dir="$apt_dir"/keyrings

# this_dir="$(dirname "$(realpath "$0")")"
# destination_keyrings_dir=$this_dir/test
mkdir -p "$destination_keyrings_dir"

keys=$(command ls "$sources_keyrings_dir")
# for k in $keys; do
# 	name="${k%.*}"
# 	# echo -E "$name"
# done

function update_apt_keyrings() {
	for k in $keys; do
		name="${k%.*}"
		recv_keys=$(gpg -k --no-default-keyring --keyring "$sources_keyrings_dir/$name.gpg" |
			grep -E "([0-9A-F]{40})" | tr -d " ")
		# echo -E "$name"
		# echo -E "$recv_keys"
		gpg --no-default-keyring \
			--keyring "$sources_keyrings_dir/$name.gpg" \
			--keyserver hkps://keyserver.ubuntu.com \
			--recv-keys "$recv_keys"
	done
}
# update_apt_keyrings

function update_gpg_keyrings() {
	recv_keys=$(gpg -k --with-colons | awk -F: '/^fpr:/ { print $10 }')
	for r in $recv_keys; do
		gpg --keyserver keyserver.ubuntu.com --recv-keys "$r"
	done
}
# update_gpg_keyrings

function to_bin_apt_keys() {
	for k in $keys; do
		name="${k%.*}"
		command cat "$sources_keyrings_dir/$name.asc" | gpg --dearmor \
			-o "$destination_keyrings_dir/$name.gpg"
	done
}

function to_ascii_apt_keys() {
	for k in $keys; do
		name="${k%.*}"
		gpg --export --armor --no-default-keyring \
			--keyring "$sources_keyrings_dir/$name.gpg" \
			-o "$destination_keyrings_dir/$name.asc"
	done
}
to_ascii_apt_keys

# echo -e "$1"
# echo -e "$2"

# gpg -k --no-default-keyring --keyring ./*.gpg

# gpg --homedir /tmp --no-default-keyring --keyring "$destination_keyrings_dir/$name" \
# gpg --list-keys --with-colons | awk -F: '/^fpr:/ { print $10 }'
# gpg --no-default-keyring --keyring /etc/apt/keyrings/brave-browser-release.gpg --with-colons --fingerprint | awk -F: '/^fpr:/ { print $10 }'
# gpg --no-default-keyring --keyring /etc/apt/keyrings/brave-browser-release.gpg --fingerprint | sed -n '/^\s/s/\s*//p'
