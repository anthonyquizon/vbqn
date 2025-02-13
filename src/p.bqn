PP←•Show 
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"


ansi←{
  e⇐@+27
  cyan⇐e∾"[36m"
  white⇐e∾"[0;37m"
  bold_white⇐e∾"[1;37m"
  reset⇐e∾"[0m"
}

lf←@+10
runtime⇐⟨
 +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,⋈,↑,↓,↕,«,»,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!,
 ˙,˜,˘,¨,⌜,⁼,´,˝,`,
 ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟,⎊,
⟩

fmap←⟨⟩ •HashMap ⟨⟩
imap←⟨⟩ •HashMap ⟨⟩ #cached imported files
pmap←⟨⟩ •HashMap ⟨⟩ #cached queries match to filenames

Info←{ 
  k←pmap.Keys @
  k↩⊑k/˜∨´¨⍷⟜𝕩¨k # take first matching files

  file  ⇐ 𝕩
  query ⇐ pmap.Get k
  src   ⇐ •file.Chars file
  lines ⇐ 1++`src=lf 
}

ctx ⇐ {
  s ⇐ ⟨⟩

  Push ⇐ { 𝕊 𝕩:
    f←𝕩∾˜(0⊸≢≠)◶""‿(•ns.Get⟜"cwd") Peek @
    {𝕩 fmap.Set Info f}⍟(¬∘fmap.Has) f
    s∾↩< { cwd⇐•file.Parent f }
    fmap.Get f
  }

  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                 # Return but don't pop top value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}             # Pop 𝕩 values; return as list
}

file⇐{
  Lines⇐{ 
    𝕩 : "/"≤○≠◶0‿(⊣≡≠⊸↑)𝕩 ? •file.Lines 𝕩 
  ; 𝕩 : ⟨cwd⟩←ctx.Peek @ ⋄ •file.Lines cwd∾𝕩 
  } 
  List ⇐{ ⟨cwd⟩←ctx.Peek @ ⋄ •file.List  cwd∾𝕩 } 
}

syslist←⟨
    "while"‿•_while_
    "hash"‿•Hash
    "parsefloat"‿•ParseFloat
    "ffi"‿•FFI
    "out"‿•Out
    "exit"‿•Exit
    "file"‿file
    "flines"‿file.Lines
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

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : imap.Has 𝕩 ? imap.Get 𝕩
; args 𝕊 𝕩 : 
    info←ctx.Push 𝕩
    c ← ⟨runtime, System args, ⟨⟩⟩⊸Compile info.src
    r ← info VM c

    𝕩 imap.Set r
    ctx.Pop 1 
    r
}

Parse←{ 𝕊 p:
  p↩{𝕩/˜0=+`𝕩='#'}¨p # remove comments
  p↩p/˜(0<≠)¨p
  m←{1≤+`𝕩=' '}¨p
  loc←•ParseFloat⎊⊣¨¨":"⊸((⊢-˜¬×·+`1⊸»⊸<)∘∊˜⊔⊢)¨(¬m)/¨p
  file←⊑¨loc
  z←¬".bqn"⊸≡¨¯4↑¨file
  file↩ (∾⟜".bqn"¨)⌾(z⊸/) file 
  g←⊐file
  q← loc { 𝕨 𝕊 ⟨p,src⟩: 
    loc⇐𝕨
    Run⇐{ 
      •Out ansi.bold_white∾p∾ansi.reset
      •Show ⟨"", "", 𝕨⟩ •BQN ∾⟨"⟨",1↓∾','⊸∾¨𝕩,"⟩← •args",lf,src⟩
    } 
  }¨p⋈¨(m/¨p)
  (⊑¨g⊔file) pmap.Set¨g⊔q
}

# === Main ===
{ 𝕊: •Out "Missing input file" ⋄ •Exit 1 }⍟(0=≠) •args
Parse•file.Lines •wdpath∾"/_p.bqn"
Run •wdpath∾"/"∾⊑•args
