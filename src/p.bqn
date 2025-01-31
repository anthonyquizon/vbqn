gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

lf←@+10
runtime⇐⟨
 +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,⋈,↑,↓,↕,«,»,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!,
 ˙,˜,˘,¨,⌜,⁼,´,˝,`,
 ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟,⎊,
⟩

fmap←⟨⟩ •HashMap ⟨⟩
imap←⟨⟩ •HashMap ⟨⟩ #cached imported files

syslist←⟨
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
    "bqn"‿•Bqn
    "repr"‿•Repr
    "type"‿•Type
⟩

System ←{ 𝕊 args:
  FindSys ← {
    i ← 𝕨⊐𝕩
    { ! ∾⟨"Unknown system value",(1≠≠𝕩)/"s",":"⟩∾" •"⊸∾¨𝕩 }∘/⟜𝕩⍟(∨´) i=≠𝕨
    i
  }

  { 𝕨⊸FindSys⊏𝕩˙ }´∾<˘⋈˘⍉>syslist∾⟨ "import"‿Import, "args"‿𝕩 ⟩
}

File←{ 
  src⇐lines⇐marks⇐@ 
  file ⇐ 𝕩
  src   ↩ •file.Chars file
  lines ↩ 1++`src=lf 
  marks ↩0∾∨´¨((≠src)↑"#?"⍷src)⊔˜+`src=lf
}

ctx ⇐ {
  s ⇐ ⟨⟩

  Push ⇐ { 𝕊 𝕩:
    f←𝕩∾˜(0⊸≢≠)◶""‿(•ns.Get⟜"cwd") Peek @
    {𝕩 fmap.Set File f}⍟(¬∘fmap.Has) f
    s∾↩< { cwd⇐•file.Parent f }
    fmap.Get f
  }

  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                 # Return but don't pop top value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}             # Pop 𝕩 values; return as list
}

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : imap.Has 𝕩 ? imap.Get 𝕩
; args 𝕊 𝕩 : 
    ⟨src, file, lines, marks⟩←ctx.Push 𝕩
    c ← ⟨runtime, System args, ⟨⟩⟩⊸Compile src
    r ← file‿lines‿marks VM c
    𝕩 imap.Set r
    ctx.Pop 1 
    r
}

Args ←{ 𝕊:
  ⟨args⟩←ctx.Peek @
  args
}

