{ config, modulesPath, ... }:
{
	imports = [
		"${toString modulesPath}/installer/cd-dvd/iso-image.nix"
	];

	# SquashFS Zstandard compression
	isoImage.squashfsCompression = "zstd -Xcompression-level 19";

	# EFI booting
	isoImage.makeEfiBootable = true;

	# BIOS booting (for 23.05 or newer)
	# isoImage.makeBiosBootable = true;

	# USB booting
	isoImage.makeUsbBootable = true;

	formatAttr = "isoImage";
	filename = "*.iso";
}
