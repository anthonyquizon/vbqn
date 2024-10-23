runtime ←    •Import "./rt.bqn"     # TODO replace runtime with host runtime - replacement mask with array of cbqn functions
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"
global  ←    •Import "./global.bqn"

imp←⟨⟩ •HashMap ⟨⟩ #cached imported files

Import ← {
  # TODO import with args
  # TODO store call in graph
  imp.Has 𝕩 ? imp.Get 𝕩;
  𝕩 : 
    ⟨cwd, ·⟩←global.ctx.Peek @

    file←cwd∾𝕩
    src←•file.Chars file
    cwd↩•file.Parent file
    global.ctx.Push ⟨cwd,src⟩

    c← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
    r←VM c
    global.ctx.Pop 1
    𝕩 imp.Set r
    r
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

