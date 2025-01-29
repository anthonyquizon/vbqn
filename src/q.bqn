gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

lf←@+10
system⇐@
runtime⇐⟨
 +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,⋈,↑,↓,↕,«,»,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!,
 ˙,˜,˘,¨,⌜,⁼,´,˝,`,
 ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟,⎊,
⟩

file_map  ←⟨⟩ •HashMap ⟨⟩
import_map←⟨⟩ •HashMap ⟨⟩ #cached imported files

Fmt←{ 
  file‿args ⇐ 𝕩
  src   ⇐ •file.Chars file
  cols  ⇐ ∾+`¨1¨¨⊔+`src=lf
  lines ⇐ 1++`src=lf 
}

ctx ⇐ {
  s ⇐ ⟨⟩

  Push ⇐ { args 𝕊 𝕩:
    f←𝕩∾˜(0⊸≢≠)◶""‿(•ns.Get⟜"cwd") Peek @
    (file_map.Set⟜Fmt⟜(f‿args))⍟(¬∘file_map.Has) f
    s∾↩< { cwd⇐•file.Parent f }
    file_map.Get f
  }

  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                 # Return but don't pop top value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}             # Pop 𝕩 values; return as list
}

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : import_map.Has 𝕩 ? import_map.Get 𝕩
; 𝕨 𝕊 𝕩 : 
    ⟨src, file, lines⟩←𝕨 ctx.Push 𝕩
    •Show src=lf
    #•Show src∊"#?"
    # TODO parse comments - if parse failed 

    c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩⊸Compile src
    # TODO return values from lines
    r ← file VM c
    𝕩 import_map.Set r
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
