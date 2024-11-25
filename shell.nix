with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    entr
    cbqn
    sqlite
  ];
}

