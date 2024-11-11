gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"
⟨ctx⟩   ←    •Import "./s.bqn"

system⇐@
runtime⇐⟨
 +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,⋈,↑,↓,↕,«,»,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!,
 ˙,˜,˘,¨,⌜,⁼,´,˝,`,
 ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟,⎊,
⟩

import_cache←⟨⟩ •HashMap ⟨⟩ #cached imported files

Import ⇐ {
  import_cache.Has 𝕩 ? import_cache.Get 𝕩;
  𝕩 : 
    ⟨src⟩←ctx.Push 𝕩
    c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
    r ← VM c
    𝕩 import_cache.Set r
    ctx.Pop 1 
    r
}

FFI ← {
  f←𝕨 •FFI 𝕩
  { •SHow "record ffi" ⋄  𝔽 𝕩 }
}

# Lookup table
systable← ∾<˘⋈˘⍉>⟨
     "ffi"‿FFI
     "out"‿•Out
    "exit"‿•Exit
    "file"‿•file
    "fmt" ‿•Fmt
    "math"‿•math
    "ns"  ‿•ns
    "show"‿•Show
    "type"‿•Type
  "import"‿Import
⟩

FindSys ← {
  i ← 𝕨⊐𝕩
  { ! ∾⟨"Unknown system value",(1≠≠𝕩)/"s",":"⟩∾" •"⊸∾¨𝕩 }∘/⟜𝕩⍟(∨´) i=≠𝕨
  i
}

system↩{ 𝕨⊸FindSys⊏𝕩˙ }´systable

