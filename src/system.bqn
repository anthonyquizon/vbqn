runtime ←    •Import "./rt.bqn"     # TODO replace runtime with host runtime - replacement mask with array of cbqn functions
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"
global  ←    •Import "./global.bqn"

Import ← {
  src←•file.Chars global.cwd∾𝕩
  c← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
  VM c
}
# Lookup table
systable← ∾<˘⋈˘⍉>⟨
    "type"‿•Type
     "out"‿•Out
    "show"‿•Show
  "import"‿Import
⟩

FindSys ← {
  i ← 𝕨⊐𝕩
  { ! ∾⟨"Unknown system value",(1≠≠𝕩)/"s",":"⟩∾" •"⊸∾¨𝕩 }∘/⟜𝕩⍟(∨´) i=≠𝕨
  i
}

system ⇐ { 𝕨⊸FindSys⊏𝕩˙ }´systable

