{
inputs = {
	nixpkgs.url = "nixpkgs/nixos-22.11";
	flake-utils.url = "github:numtide/flake-utils";
	nixos-generators = {
		url = "github:nix-community/nixos-generators";
		inputs.nixpkgs.follows = "nixpkgs";
	};
};

outputs = { self, nixpkgs, nixos-generators, flake-utils, ... }:
	flake-utils.lib.eachDefaultSystem (system:
		let pkgs = import nixpkgs {
			system = "i686-linux";
		};
		in {
			packages.quecto = nixos-generators.nixosGenerate {
				customFormats = { "universal-iso" = { imports = [ ./universal-iso.nix ]; }; };
				pkgs = pkgs;
				system = "i686-linux";
				format = "universal-iso";

				modules = [{
					system.nixos.label = "Quecto";
					system.stateVersion = "22.11";
					users.users.root.password = "root";

					services.xserver = {
						enable = true;
						desktopManager.cde.enable = true;
						displayManager = {
							defaultSession = "CDE";
							sddm = {
								enable = true;
								autoLogin.minimumUid = 0;
							};
							autoLogin = {
								enable = true;
								user = "root";
							};
						};
					};
					
					fileSystems."/root" = {
						device = "/dev/disk/by-label/Quecto";
						options = [ "nofail" ];
					};

					environment.systemPackages = with pkgs; [
						neofetch
						netsurf-browser
						btrfs-progs
					];
				}];
			};
		}
	);
}
