gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"
⟨ctx⟩   ←    •Import "./s.bqn"

# Store cwd and src in stack and run compiler with provided runtime and system functions
Error← {𝕊: 
  •Out "Error:"∾•CurrentError@
  •Out "TODO show stack trace and stop recording"
}

Run⇐{
  sys‿rt 𝕊 𝕩:
    ⟨src⟩←ctx.Push 𝕩
    c ← ⟨rt, { Sys 𝕩 }, ⟨⟩⟩ Compile src
    r ← VM⎊Error c
    ctx.Pop 1 
    r
}


