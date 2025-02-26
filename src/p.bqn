gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

ansi←{
  e⇐@+27
  bold_cyan⇐e∾"[1;36m"
  reset⇐e∾"[0m"
}

pfile←".p.bqn"

lf←@+10

fmap←⟨⟩ •HashMap ⟨⟩
imap←⟨⟩ •HashMap ⟨⟩ #cached imported files
pmap←⟨⟩ •HashMap ⟨⟩ #cached queries match to filenames

Info←{ 
  k←pmap.Keys @

  z←𝕩/˜¬".bqn"⊸≡¨¯4↑¨𝕩 
  k↩k/˜∨´¨⍷⟜z¨k # take first matching files

  ("Missing file " ∾ 𝕩) ! •file.Exists 𝕩

  file  ⇐ 𝕩
  query ⇐ (0⊸≠≠)◶⟨⟩‿(pmap.Get∘⊑) k
  src   ⇐ •file.Chars file
  lines ⇐ •file.Lines file
  ln    ⇐ 1++`src=lf  # line numbers #TODO remove line 1 offset
  col   ⇐ ∾(↕≠)¨⊔˜+`src=@+10
  #∾(↕≠)¨lines # column numbers
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

# Debug stack: keep track of calls
dbg ← {
  s ← ⟨⟩                          # Stack (a list)
  Push  ⇐ {s∾↩<𝕩 } # p: start/end position of call
  Pop   ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s} # Pop 𝕩 values; return as list
  Print ⇐ { 𝕊: 
    •Out "Error: " ∾ •CurrentError@
    {𝕊 off‿col‿ln‿file : 
      info←fmap.Get file
      •Out ∾⟨file/˜¬(1¨↕1-˜≠p)∾(p←•wdpath∾'/')⍷file,':',•Fmt ln⟩
      •Out ∾⟨"  ",(ln-1)⊑info.lines⟩
      •Out ∾⟨"  ",(' '¨↕col), '∧'¨↕off+1⟩
    }¨⌽s
  }
}

file⇐{
  Lines⇐{ 
    𝕩 : "/"≤○≠◶0‿(⊣≡≠⊸↑)𝕩 ? •file.Lines 𝕩 
  ; 𝕩 : ⟨cwd⟩←ctx.Peek @ ⋄ •file.Lines cwd∾𝕩 
  } 
  List ⇐{ ⟨cwd⟩←ctx.Peek @ ⋄ •file.List  cwd∾𝕩 } 
}

syslist←⟨
    "p"‿•Show # TODO show file and line number
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

CmpCatch←{ info 𝕊 src:
  ⟨lines,file⟩←info
  ⟨loc,msg⟩←•CurrentError@
  s‿e←loc↩⥊loc
  ln←lines⊑˜⊑loc
  m←∨´lines⊸=¨lines⊏˜loc
  •Out "Error: "∾msg
  •Out file∾":"∾•Fmt ln
  •Out 1↓m/src
  •Out ⊣◶" ∧"¨«(m/↕≠src)∊(s+↕1+e-s)
  •Exit 1
}

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : imap.Has 𝕩 ? imap.Get 𝕩
; args 𝕊 𝕩 : 
    info←ctx.Push 𝕩

    c ← (⟨1⊸⊑¨•primitives, System args, ⟨⟩⟩⊸Compile)⎊(info⊸CmpCatch) info.src
    r ← info‿dbg VM c

    𝕩 imap.Set r
    ctx.Pop 1 
    r
}

PBQNFile←{ 
  𝕊 𝕩 : •file.Exists 𝕩 ? 
    p←•file.Lines 𝕩
    p↩{𝕩/˜0=+`𝕩='#'}¨p        # remove comments
    p↩{(∨`∧∨`⌾⌽)' '≠𝕩}⊸/¨p    # remove empty lines
    p↩p/˜(0<≠)¨p
    m←{1≤+`𝕩=' '}¨p
    loc←•ParseFloat⎊⊣¨¨":"⊸((⊢-˜¬×·+`1⊸»⊸<)∘∊˜⊔⊢)¨(¬m)/¨p
    file←⊑¨loc
    g←⊐file
    q← loc { 𝕨 𝕊 ⟨p,src⟩: 
      bkt←1⊑𝕨
      Run⇐{ 
        h 𝕊 ln: bkt≡ln ?
          #h.Keys@, h.Values@
          •Out ansi.bold_cyan∾p∾ansi.reset
          #bqn← •ReBQN {system⇐⟨"show"‿•Show, "p"‿•Show, "args"‿v⟩}
          #•Show BQN "•args"
          #•Show  BQN ∾⟨"⟨",1↓∾','⊸∾¨n,"⟩← •args",lf,src⟩
      ; @
      } 
    }¨p⋈¨(m/¨p)
    (⊑¨g⊔file) pmap.Set¨g⊔q
; 𝕊 𝕩 : •Out "Missing pbqn file " ∾ 𝕩
}

usage←∾∾⟜lf¨⟨
  "Usage: pbqn [options] [file.bqn [arguments]]"
  "Options:"
  "  -p file   query file"
⟩

# === Main ===
{
  {𝕊: •Out usage ⋄ •Exit 0}⍟(0⊸=) ≠•args 
  f←(¬∘(⊣∨»)"-p"⊸≡¨)⊸/•args ⋄ "Missing input file" ! 1≥≠f
  p←(0⊸<≠)◶pfile‿⊑  (»"-p"⊸≡¨)⊸/•args
  PBQNFile •wdpath∾'/'∾p
  Run •wdpath∾"/"∾⊑f
}
