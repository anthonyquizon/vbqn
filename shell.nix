with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    entr
    replxx
    cbqn-replxx
    sqlite
  ];
}

