{
inputs = {
	nixpkgs.url = "nixpkgs/nixos-23.05";
	flake-utils.url = "github:numtide/flake-utils";
	nixos-generators = {
		url = "github:nix-community/nixos-generators";
		inputs.nixpkgs.follows = "nixpkgs";
	};
};

outputs = { self, nixpkgs, nixos-generators, flake-utils, ... }:
	flake-utils.lib.eachDefaultSystem (system:
		# NixOS i686 repository
		let pkgs = import nixpkgs {
			system = "i686-linux";
		};
		in {
			# Quecto derivation 
			packages.quecto = nixos-generators.nixosGenerate {
				customFormats = { "universal-iso" = { imports = [ ./universal-iso.nix ]; }; };
				pkgs = pkgs;
				system = "i686-linux";
				format = "universal-iso";

				# System module, describing OS configuration and packages
				modules = [{
					system.nixos.label = "Quecto";
					system.stateVersion = "23.05";
					nix.settings = {
						auto-optimise-store = true;
						experimental-features = [ "nix-command" "flakes" ];
					};
					users.users.root.password = "root";

					services.xserver = {
						enable = true;
						desktopManager.cde.enable = true;
						libinput = {
							enable = true;
							touchpad.middleEmulation = true;
							touchpad.tapping = true;
						};
						displayManager.startx.enable = true;
					};

					systemd = {
						# CDE session autostart
						defaultUnit = "graphical.target";
						services.cde = {
							enable = true;
							after = [ "systemd-user-sessions.service" ];
							wantedBy = [ "graphical.target" ];
							serviceConfig = {
								User = "root";
								WorkingDirectory = "~";
								PAMName = "login";
								Environment = [ "XDG_SESSION_TYPE=x11" ];
								ExecStart = "${pkgs.xorg.xinit}/bin/startx ${pkgs.cdesktopenv}/opt/dt/bin/Xsession";
								ExecStopPost = "/run/current-system/sw/bin/reboot";
							};
						};

						# User storage
						## Data can be saved on storage using a partition labeled "Quecto"
						## The partition is set as /root and contains a Nix store overlay
						services.nix-user-pre = {
							requires = [ "root.mount" ];
							serviceConfig.ExecStart =
								"${pkgs.coreutils}/bin/mkdir -p /root/.nix /root/.cache/db "
								+ "/root/.cache/overlay /root/.cache/overlay-db";
						};
						services.nix-user = {
							serviceConfig = { type = "oneshot"; };
							requires = [ "root.mount" "nix-user-pre.service" "nix-store.mount" ];
							wantedBy = [ "nix-daemon.socket" ];
							script = "${pkgs.util-linux}/bin/mount -t overlay overlay -o "
								+ "lowerdir=/nix/store,"
								+ "upperdir=/root/.nix,"
								+ "workdir=/root/.cache/overlay "
								+ "/nix/store";
						};
						services.nix-user-db = {
							serviceConfig = { type = "oneshot"; };
							requires = [ "root.mount" "nix-user-pre.service" "nix-user.service" ];
							wantedBy = [ "nix-daemon.socket" ];
							script = "${pkgs.util-linux}/bin/mount -t overlay overlay -o "
								+ "lowerdir=/nix/var/nix/db,"
								+ "upperdir=/root/.cache/db,"
								+ "workdir=/root/.cache/overlay-db "
								+ "/nix/var/nix/db";
						};
					};
					fileSystems."/root" = {
						device = "PARTLABEL=Quecto";
						neededForBoot = true;
						options = [
							"nofail"
							"x-systemd.device-timeout=15s"
						];
					};
					boot.initrd.supportedFilesystems = [ "btrfs" ];

					# Global packages without related NixOS options
					environment = {
						systemPackages = with pkgs; [
							bash-completion
							git
							neofetch
							netsurf-browser
							btrfs-progs
							cryptsetup
						];
					};
				}];
			};
		}
	);
}
