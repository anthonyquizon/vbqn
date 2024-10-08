with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    entr
    gcc
    clang
    && #lldb
    libffi
  ];
}

