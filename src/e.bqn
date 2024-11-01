gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"
state   ←    •Import "./s.bqn"

# Store cwd and src in stack and run compiler with provided runtime and system functions
Run⇐{
  sys‿rt 𝕊 𝕩:
    ·‿src‿·←state.Push 𝕩
    c ← ⟨rt, { Sys 𝕩 }, ⟨⟩⟩ Compile src
    r ← VM c ⋄ state.Pop @ ⋄ r
}

