#!/bin/bash
# shellcheck disable=SC2329

set -uo pipefail
sdir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]:-$0}")")

function _deps {
	echo 'attempting to install deps: dra, 7zip, genisoimage'
	brew install dra
	sudo apt install -y 7zip genisoimage
}

function _unpack {
	declare src_iso=${1}
	declare iso_unpacked=${2:-"$sdir\iso"}

	7z x "$src_iso" -o"$iso_unpacked"
}

function _pkg {
	declare src_repo=${1:-"$sdir"}
	declare iso_unpacked=${2:-"$sdir/iso"}
	declare iso_packed=${3:-"$sdir/auto_win.iso"}
	declare clean=${4:-true}

	dst="$iso_unpacked/sources/\$OEM\$/\$1/Users/Default/unattend/"
	if $clean; then
		echo "cleaning repo files from unpacked iso"
		rm -rf "$dst"
		rm -f "$iso_unpacked\autounattend.xml"
		rm -f "$iso_packed"
	fi
	mkdir -p "$dst"

	if [ ! -f amecli.zip ]; then
		echo 'downloading ame cli from github release to amecli.zip'
		dra download -s 'CLI-Standalone.zip' -o amecli.zip Ameliorated-LLC/trusted-uninstaller-cli
	fi
	if [ ! -d "$src_repo/amecli" ]; then
		echo "unzipping ame cli into $src_repo/amecli"
		7z x amecli.zip -o"$src_repo/amecli"
		# they added a zip of this release ... inside the release?
		rm -f "$src_repo/amecli/CLI-standalone.zip"
	fi

	echo 'copying repo files into unpacked iso folder'
	cp -f "$src_repo/autounattend.xml" "$iso_unpacked"
	cp -rf "$src_repo/amecli" "$dst"
	cp -rf "$src_repo/lib" "$dst"
	cp -rf "$src_repo/playbook" "$dst"
	cp -f "$src_repo/"*.yml "$dst"
	cp -f "$src_repo/"*.ps1 "$dst"

	echo "packing iso folder: $iso_unpacked into iso image: $iso_packed"
	genisoimage \
		--allow-limited-size \
		-no-emul-boot \
		-b "boot/etfsboot.com" \
		-boot-load-seg 0 \
		-boot-load-size 8 \
		-eltorito-alt-boot \
		-no-emul-boot \
		-e "efi/microsoft/boot/efisys.bin" \
		-boot-load-size 1 \
		-iso-level 4 \
		-udf \
		-o "$iso_packed" \
		"$iso_unpacked" \
		&>/dev/null
}

function _help {
	cat <<'END' >&2
iso.sh summary:
    Unpack a windows iso image; repack files with unattend repo files into a bootable windows iso

usage:
    ./iso.sh <cmd> [args...]

commands:
    help
        print help
    unpack
        unpack <file.iso> [unpacked_path]
        unpack <file.iso> ./iso (default)
    pkg
        pkg [repo] [unpacked_iso_path] [iso_output_path] [bool: clean]
        pkg ./ ./iso ./auto_win.iso true (default)
    deps
        Install dependency packages used by the `pkg` command (dra, 7zip)
        The command attempts to install using brew and apt package managers, but you can install these however you'd like
END
}

function main {
	declare mode=${1:-"help"}
	shift

	if ! declare -F "_$mode" >/dev/null; then
		_help
		return 1
	fi
	"_$mode" "$@"
}

main "$@"
echo -e "\nexited with code: $?"
exit
