with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    entr
    clang
    replxx
    lldb
    libffi
  ];
}

