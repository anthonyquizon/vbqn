gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

no_col←1

ansi←{
  e⇐@+27
  BoldCyan⇐{𝕊:no_col?"";e∾"[1;36m"}
  Red     ⇐{𝕊:no_col?"";e∾"[31m"}
  Magenta ⇐{𝕊:no_col?"";e∾"[35m"}
  BoldRed ⇐{𝕊:no_col?"";e∾"[1;31m"}
  Reset   ⇐{𝕊:no_col?"";e∾"[0m"}
}

lf←@+10
fm←⟨⟩ •HashMap ⟨⟩ #cached file information
im←⟨⟩ •HashMap ⟨⟩ #cached imported files
pm←⟨⟩ •HashMap ⟨⟩ #cached queries match to filenames

Info←{ 
  f ⇐ 𝕩∾".bqn"⋄("Missing file "∾f)!•file.Exists f # filename
  s ⇐ •file.Chars f                 # source files in chars
  l ⇐ (lf⊸≠)⊸/¨s⊔˜»+`lf=s           # source file in lines
  n ⇐ +`s=lf                        # line numbers
  c ⇐ ∾(↕≠)¨⊔˜+`s=@+10              # column numbers
  m ⇐ ≠/˜⌽0<+`⌽¬(0⊸=≠¨l)∨∧´¨' '⊸=¨l # maximum line number TODO delete - instead snap to nearest line above
}

ctx ⇐ {
  s ⇐ ⟨⟩
  Push ⇐ { 𝕊 𝕩:
    f←𝕩∾˜(0⊸≢≠)◶""‿⊣ Peek @
    f↩f/˜¬+`(≠↑".bqn"⊸⍷)f # normalize: remove .bqn
    {𝕩 fm.Set Info 𝕩}⍟(¬∘fm.Has) f
    s∾↩<f
    fm.Get f
  }

  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                 # Return but don't pop top value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}             # Pop 𝕩 values; return as list
}

# Debug stack: keep track of calls
dbg ← {
  s ← ⟨⟩                          
  Push  ⇐ { 𝕊 pos‿loc: # pos: index position of bytecode, loc: start/end position of call
    i←fm.Get ctx.Peek @
    o←|-´(pos-1)⊑¨loc       # offset
    c←i.c⊑˜1-˜⊑(pos-1)⊑¨loc # column
    l←i.n⊑˜pos⊑⊑loc         # line
    f←i.f                   # file
    s∾↩<o‿c‿l‿f 
  } 
  Pop   ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s} # Pop 𝕩 values; return as list
  Print ⇐ { 𝕊: 
    •Out ∾⟨ansi.BoldRed@,"Error: ", •CurrentError@,ansi.Reset@⟩
    {𝕊 o‿c‿l‿f : 
      i←fm.Get f
      •Out ∾⟨ansi.Red, f/˜¬(1¨↕1-˜≠p)∾(p←•wdpath∾'/')⍷f,':',•Fmt l, ansi.Reset@⟩
      •Out ∾⟨"  ",(l-1)⊑i.l⟩
      •Out ∾⟨ansi.Red@, "  ",(' '¨↕c), '∧'¨↕o+1, ansi.Reset@⟩
    }¨⌽s
  }
}

sysfile⇐{
  Lines⇐{ 
    𝕩 : "/"≤○≠◶0‿(⊣≡≠⊸↑)𝕩 ? •file.Lines 𝕩 
  ; 𝕩 : •file.Lines ∾⟜𝕩 •file.Parent ctx.Peek @ ⋄ 
  } 
  List ⇐{ •file.List ∾⟜𝕩 •file.Parent ctx.Peek @ } 
}

syslist←⟨
    "p"‿•Show # TODO show file and line number
    "while"‿•_while_
    "hash"‿•Hash
    "parsefloat"‿•ParseFloat
    "ffi"‿•FFI
    "out"‿•Out
    "exit"‿•Exit
    "file"‿sysfile
    "flines"‿sysfile.Lines
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

CmpCatch←{ 𝕊 src:
  in←ctx.Peek@⋄⟨loc,msg⟩←•CurrentError@⋄s‿e←loc↩⥊loc
  •Out "Error: "∾msg
  •Out in.f∾":"∾ •Fmt s⊑in.n
  •Out (s⊑in.n)⊑in.l
  •Out ⊣◶" ∧"¨«((↕≠src)/˜∨´in.n⊸=¨loc⊏in.n)∊s+↕1+e-s
  •Exit 1
}

MakeInsp←{𝕊:
  f←ctx.Peek @ ⋄ in←fm.Get f ⋄ q←pm.Has◶⟨⟩‿pm.Get f
  i←@ ⋄ ls←@

  Pre⇐{pos‿loc:ls↩in.n⊑˜pos⊑⊑loc}
  Run⇐{
    · 𝕊 ·: 0≡≠q? @
  ; h 𝕊 pos‿loc: l←in.n⊑˜(pos-1)⊑⊑loc⋄ls≠l ?  # TODO if values have changed, not line
    bqn←•ReBQN {system⇐⟨"args"‿(h.Values@), "i"‿i, "l"‿l⟩}
    # TODO inject 𝕩 and 𝕨 arguments
    Eval←{Bqn ∾⟨"⟨",1↓∾','⊸∾¨(h.Keys@),"⟩←•args",lf,𝕩⟩}

    {
     •Out ∾⟨ansi.BoldCyan@,0⊑𝕩,':',•Fmt 1⊑𝕩,' ',2⊑𝕩,ansi.Reset@⟩
     •Show Eval 2⊑𝕩
    }¨q/˜l=1⊸⊑¨q # mask all valid line number queries # TODO conditional queries mask

    ls↩l
  ; @
  }
}

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : im.Has 𝕩 ? im.Get 𝕩
; args 𝕊 𝕩 : 
    in←ctx.Push 𝕩
    insp←MakeInsp @

    c ← (⟨1⊸⊑¨•primitives, System args, ⟨⟩⟩⊸Compile)⎊CmpCatch in.s
    # TODO parse all locations and snap to nearest
    r ← insp‿dbg VM c
    𝕩 im.Set r
    ctx.Pop 1 
    r
}

usage←∾∾⟜lf¨⟨
  "Usage: pbqn [options] [file.bqn [arguments]]"
  "Options:"
  "  -p file   query file"
⟩

# === Main ===
{
  {𝕊:•Out usage⋄•Exit 0}⍟(0⊸=)≠•args 

  # parse PBQN files
  p←•wdpath∾'/'∾(0⊸<≠)◶".v.bqn"‿⊑  (»"-v"⊸≡¨)⊸/•args
  p↩•file.Exists◶{𝕊: •Out "Missing .v.bqn file"⋄⟨⟩}‿•file.Lines p
  p↩{𝕩/˜0=+`𝕩='#'}¨p                   # remove comments
  p↩{(∨`∧∨`⌾⌽)' '≠𝕩}⊸/¨p               # trim whitespace
  p↩p/˜(0<≠)¨p                         # remove empty lines
  p↩{𝕩⊔˜○((¬':'=𝕩)⊸/)+´(⌈`=⟜𝕩)¨": "}¨p # parse into groups file:line query (TODO parse : not in {} or ())
  p↩•ParseFloat⎊⊣¨¨p
  p((·⊑¨⊐∘⊢⊔⊢)pm.Set¨(⊢⟜⊐⊔⊣)) (•wdpath∾'/'∾0⊸⊑)¨p # store queries in pm 

  •Out ∾⟨ansi.Magenta@,"--",ansi.Reset@⟩ # print start of run marker
  (0≠≠)◶("Missing input file"⊸!)‿{Run•wdpath∾'/'∾∾𝕩} (¬∘(⊣∨»)"-v"⊸≡¨)⊸/•args 
}
