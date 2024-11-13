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
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : import_cache.Has 𝕩 ? import_cache.Get 𝕩
; 𝕨 𝕊 𝕩 : 
    ⟨src, file, lines⟩←𝕨 ctx.Push 𝕩
    # FIXME cleanup
    Catch ← 𝕩⊸{ 𝕊:
      ⟨loc, msg⟩← •CurrentError @
      s‿e←loc↩⥊loc
      ln←lines⊑˜⊑loc # line number
      m←∨´lines⊸=¨lines⊏˜loc
      m/↕≠src
      l←1↓m/src
      s+↕1+e-s
      
      •Out "Error: "∾msg
      •Out 𝕨∾":"∾•Fmt ln
      •Out l
      •Out ⊣◶" ∧"¨«(m/↕≠src)∊(s+↕1+e-s)
      •Exit 1
    }
    #c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
    c ← (⟨runtime, { System 𝕩 }, ⟨⟩⟩⊸Compile)⎊Catch src

    r ← file VM c
    𝕩 import_cache.Set r
    ctx.Pop 1 
    r
}

Args ← { 𝕊:
  ⟨args⟩←ctx.Peek @
  args
}

FFI ← {
  f←𝕨 •FFI 𝕩
  { •SHow "record ffi" ⋄  𝔽 𝕩 }
}

# Lookup table
systable← ∾<˘⋈˘⍉>⟨
     "args"‿Args
     "while"‿•_while_
     "hash"‿•Hash
     "parsefloat"‿•ParseFloat
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

