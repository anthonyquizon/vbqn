#bar ← •Import "bar.bqn"
#ffi←"./lib.so" •FFI "u32"‿"u32"
b←2
G←{ b+⟜𝕩↩ ⋄ b }

G 1
G 2

#G a
#G b
#F b

#FFI 1
#FFI 2
#FFI 3
