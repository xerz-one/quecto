{ config, modulesPath, ... }:
{
	imports = [
		"${toString modulesPath}/installer/cd-dvd/iso-image.nix"
	];

	# EFI booting
	isoImage.makeEfiBootable = true;

	# BIOS booting
	isoImage.makeBiosBootable = true;

	# USB booting
	isoImage.makeUsbBootable = true;

	formatAttr = "isoImage";
	filename = "*.iso";
}
