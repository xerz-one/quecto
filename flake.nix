{
inputs = {
	nixpkgs.url = "nixpkgs/nixos-unstable";
	flake-utils.url = "github:numtide/flake-utils";
	nixos-generators = {
		url = "github:nix-community/nixos-generators";
		inputs.nixpkgs.follows = "nixpkgs";
	};
};

outputs = { self, nixpkgs, nixos-generators, flake-utils, ... }:
	flake-utils.lib.eachDefaultSystem (system:
		let pkgs = nixpkgs.legacyPackages.${system};
		in {
			packages.quecto = nixos-generators.nixosGenerate {
				system = "i686-linux";
				format = "iso";
				modules = [{
					system.stateVersion = "unstable";
					users.users.root.password = "nixos";
					environment.systemPackages = with pkgs; [ neofetch ];
				}];
			};
		}
	);
}
