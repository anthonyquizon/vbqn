runtime ←    •Import "./rt.bqn"     # TODO replace runtime with host runtime - replacement mask with array of cbqn functions
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"
global  ←    •Import "./global.bqn"

⟨system⟩ ← •Import "./system.bqn"

file←"../test/foo.bqn"
global.SetCWD •file.Parent file

src←•file.Chars file
c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
•Show VM c
