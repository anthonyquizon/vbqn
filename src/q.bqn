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

fmap←⟨⟩ •HashMap ⟨⟩
imap←⟨⟩ •HashMap ⟨⟩ #cached imported files

File←{ 
  src⇐lines⇐marks⇐@ 
  file‿args ⇐ 𝕩
  src   ↩ •file.Chars file
  lines ↩ 1++`src=lf 
  marks ↩0∾∨´¨((≠src)↑"#?"⍷src)⊔˜+`src=lf
}

ctx ⇐ {
  s ⇐ ⟨⟩

  Push ⇐ { args 𝕊 𝕩:
    f←𝕩∾˜(0⊸≢≠)◶""‿(•ns.Get⟜"cwd") Peek @
    (fmap.Set⟜File⟜(f‿args))⍟(¬∘fmap.Has) f
    s∾↩< { cwd⇐•file.Parent f }
    fmap.Get f
  }

  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                 # Return but don't pop top value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}             # Pop 𝕩 values; return as list
}

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : imap.Has 𝕩 ? imap.Get 𝕩
; 𝕨 𝕊 𝕩 : 
    ⟨src, file, lines, marks⟩←𝕨 ctx.Push 𝕩
    c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩⊸Compile src
    r ← file‿lines‿marks VM c
    𝕩 imap.Set r
    ctx.Pop 1 
    r
}

# query modifiers
# [condition] [string] •_f [values]

# Lookup table
systable← ∾<˘⋈˘⍉>⟨
    #"args"‿Args
    "while"‿•_while_
    "hash"‿•Hash
    "parsefloat"‿•ParseFloat
    "ffi"‿•FFI
    "out"‿•Out
    "exit"‿•Exit
    "file"‿•file
    "fmt" ‿•File
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
