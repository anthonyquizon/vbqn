gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"
global  ←    •Import "./global.bqn"

⟨system, runtime⟩ ← •Import "./provide.bqn"

file←"../test/foo.bqn"
cwd←•file.Parent file
src←•file.Chars file
global.ctx.Push ⟨cwd,src⟩

c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
VM c
