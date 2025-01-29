s       ←    •Import "s.bqn"
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

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : import_cache.Has 𝕩 ? import_cache.Get 𝕩
; 𝕨 𝕊 𝕩 : 
    ⟨src, file, lines⟩←𝕨 ctx.Push 𝕩
    c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩⊸Compile src
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

Show←{
  
  •Show 𝕩
}


# query modifiers
# [condition] [string] •_f [values]

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


# === Main ===
{ 𝕊: •Out "Missing input file" ⋄ •Exit 1 }⍟(0=≠) •args

Path←{•wdpath∾"/"∾𝕩}

Run ⊑Path¨•args
input← •FLines "/dev/fd/0"
