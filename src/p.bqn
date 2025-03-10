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
  lines ⇐ (lf⊸≠)⊸/¨src⊔˜»+`lf=src
  ln    ⇐ +`src=lf  
  col   ⇐ ∾(↕≠)¨⊔˜+`src=@+10
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
      •Out ∾⟨ansi.bold_cyan, file/˜¬(1¨↕1-˜≠p)∾(p←•wdpath∾'/')⍷file,':',•Fmt ln, ansi.reset⟩
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
  ⟨loc,msg⟩←•CurrentError@
  s‿e←loc↩⥊loc # convert to ⟨s,e⟩
  m←∨´info.ln⊸=¨loc⊏info.ln # 
  •Out "Error: "∾msg
  •Out info.file∾":"∾ •Fmt s⊑info.ln
  •Out (s⊑info.ln)⊑info.lines
  •Out ⊣◶" ∧"¨«(m/↕≠src)∊(s+↕1+e-s)
  •Exit 1
}

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : imap.Has 𝕩 ? imap.Get 𝕩
; args 𝕊 𝕩 : 
    info←ctx.Push 𝕩

    c ← (⟨1⊸⊑¨•primitives, System args, ⟨⟩⟩⊸Compile)⎊(info⊸CmpCatch) info.src
    r ← {info⇐info⋄dbg⇐dbg} VM c

    𝕩 imap.Set r
    ctx.Pop 1 
    r
}

BQN←{
  k←𝕨.Keys@ ⋄ v←𝕨.Values@
  eval←•ReBQN {system⇐⟨"show"‿•Show, "p"‿•Show, "args"‿v⟩}
  Eval ∾⟨"⟨",1↓∾','⊸∾¨k,"⟩← •args",lf,𝕩⟩
}

MakeQuery⇐{ f‿b‿c 𝕊 p‿src:
  n←0

  Cond←{ 
    c≡1 ? 1 ;
      n←n+1
      1≡𝕩 Bqn c # TODO line number
  }

  Run⇐{ 
    h 𝕊 cmp‿ln: (b≡ln)◶0‿Cond h ? 
      k←h.Keys@ ⋄ v←h.Values@
      •Out ansi.bold_cyan∾p∾ansi.reset
      •Show h Bqn src
  ; @
  } 
}

PBQNFile←{ 
  𝕊 𝕩 : •file.Exists 𝕩 ? 
    p←•file.Lines 𝕩
    p↩{𝕩/˜0=+`𝕩='#'}¨p        # remove comments
    p↩{(∨`∧∨`⌾⌽)' '≠𝕩}⊸/¨p    # remove empty lines
    p↩p/˜(0<≠)¨p
    m←{1≤+`𝕩=' '}¨p
    l←•ParseFloat⎊⊣¨¨":"⊸((⊢-˜¬×·+`1⊸»⊸<)∘∊˜⊔⊢)¨(¬m)/¨p
    f←⊑¨l↩(3↑∾⟜1)¨l # enforce default conditional value
    q←l MakeQuery¨p⋈¨m/¨p
    (⊑¨⊐⊸⊔f) pmap.Set¨q⊔˜⊐f # store queries matched to filenames
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
  f←(¬∘(⊣∨»)"-p"⊸≡¨)⊸/•args ⋄ "Missing input file" ! 0<≠f
  p←(0⊸<≠)◶pfile‿⊑  (»"-p"⊸≡¨)⊸/•args
  PBQNFile •wdpath∾'/'∾p
  •Out "--PBQN--"
  Run •wdpath∾"/"∾⊑f
}
