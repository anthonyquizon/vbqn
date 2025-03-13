gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

ansi←{
  e⇐@+27
  bold_cyan⇐e∾"[1;36m"
  red      ⇐e∾"[31m"
  magenta  ⇐e∾"[35m"
  bold_red ⇐e∾"[1;31m"
  reset    ⇐e∾"[0m"
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
  m ⇐ ≠/˜⌽0<+`⌽¬(0⊸=≠¨l)∨∧´¨' '⊸=¨l # maximum line number
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
    •Out ∾⟨ansi.bold_red,"Error: ", •CurrentError@,ansi.reset⟩
    {𝕊 o‿c‿l‿f : 
      i←fm.Get f
      •Out ∾⟨ansi.red, f/˜¬(1¨↕1-˜≠p)∾(p←•wdpath∾'/')⍷f,':',•Fmt l, ansi.reset⟩
      •Out ∾⟨"  ",(l-1)⊑i.l⟩
      •Out ∾⟨ansi.red, "  ",(' '¨↕c), '∧'¨↕o+1, ansi.reset⟩
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
  in←ctx.Peek@
  ⟨loc,msg⟩←•CurrentError@
  s‿e←loc↩⥊loc # convert to ⟨s,e⟩
  m←∨´in.n⊸=¨loc⊏in.n # 
  •Out "Error: "∾msg
  •Out in.f∾":"∾ •Fmt s⊑in.n
  •Out (s⊑in.n)⊑in.l
  •Out ⊣◶" ∧"¨«(m/↕≠src)∊(s+↕1+e-s)
  •Exit 1
}

MakeInsp←{𝕊:
  f←ctx.Peek @ ⋄ in←fm.Get f ⋄ q←pm.Has◶⟨⟩‿pm.Get f
  i←@ ⋄ ls←@

  •Show pm.Values@
  •Show pm.Keys@
  Pre⇐{pos‿loc:ls↩in.n⊑˜pos⊑⊑loc}
  #Cond←{ c≡1 ? 1 ; n↩n+1 ⋄ 1≡ 𝕩‿⟨"n"‿n⟩ Bqn c }
  Run⇐{ 
    # TODO type
    · 𝕊 ·: 0≡≠q? @
  ; h 𝕊 pos‿loc: 
      l←in.n⊑˜(pos-1)⊑⊑loc ⋄ k←h.Keys@ ⋄ v←h.Values@
      bqn←•ReBQN {system⇐⟨"args"‿v, "i"‿i, "l"‿l⟩}
      Eval←{Bqn ∾⟨"⟨",1↓∾','⊸∾¨k,"⟩←•args",lf,𝕩⟩}

      #•Show m←{·‿s: Eval s}¨q
      #{𝕊:(EnvVars env)⊸{𝕨 𝕩.Run lst+1}¨info.query}⍟(1⊸≡) (lst≠ln) 

      #ln ← Line@
      #lst↩ln
  }
}

Run⇐Import ⇐ {
    𝕊 𝕩 : ⟨⟩ 𝕊 𝕩
; · 𝕊 𝕩 : im.Has 𝕩 ? im.Get 𝕩
; args 𝕊 𝕩 : 
    in←ctx.Push 𝕩
    insp←MakeInsp @

    c ← (⟨1⊸⊑¨•primitives, System args, ⟨⟩⟩⊸Compile)⎊CmpCatch in.s
    r ← insp‿dbg VM c
    𝕩 im.Set r
    ctx.Pop 1 
    r
}

# f: file to query
# b: breakpoint to run query code
# c: conditional code to run to decide if src will be run
#MakeQuery0⇐{ f‿b‿c 𝕊 p‿src: 
  #{(•wdpath∾'/'∾𝕩∾".bqn") fm.Set Info •wdpath∾'/'∾𝕩∾".bqn"}⍟(¬∘fm.Has)¨f
  #info←fm.Get •wdpath∾'/'∾f∾".bqn"
  #•Show b↩info.max⌊b
  #n←0
  #Cond←{ c≡1 ? 1 ; n↩n+1 ⋄ 1≡ 𝕩‿⟨"n"‿n⟩ Bqn c }
  #Run⇐{ 
    ##h 𝕊 ln: (•Show b≡ln)◶0‿Cond h ? 
    #h 𝕊 ln: (b≡•Show ln) ? 
      #•Out ansi.bold_cyan∾p∾ansi.reset
      #•Show h‿⟨⟩ Bqn src
  #; @
  #} 
#}

usage←∾∾⟜lf¨⟨
  "Usage: pbqn [options] [file.bqn [arguments]]"
  "Options:"
  "  -p file   query file"
⟩

# === Main ===
{
  {𝕊:•Out usage⋄•Exit 0}⍟(0⊸=)≠•args 

  # parse PBQN files
  p←•wdpath∾'/'∾(0⊸<≠)◶".p.bqn"‿⊑  (»"-p"⊸≡¨)⊸/•args
  p↩•file.Exists◶{𝕊: •Out "Missing .p.bqn file"⋄⟨⟩}‿•file.Lines p
  p↩{𝕩/˜0=+`𝕩='#'}¨p                   # remove comments
  p↩{(∨`∧∨`⌾⌽)' '≠𝕩}⊸/¨p               # trim whitespace
  p↩p/˜(0<≠)¨p                         # remove empty lines
  p↩{𝕩⊔˜○((¬':'=𝕩)⊸/)+´(⌈`=⟜𝕩)¨": "}¨p # parse into groups file:line query (TODO parse : not in {} or ())
  p↩•ParseFloat⎊⊣¨¨p
  (1⊸↓¨p)((·⊑¨⊐∘⊢⊔⊢)pm.Set¨(⊢⟜⊐⊔⊣))⊑¨p # store queries in pm 

  •Out ∾⟨ansi.magenta,"--",ansi.reset⟩ # print start of run marker
  (0≠≠)◶("Missing input file"⊸!)‿{Run•wdpath∾'/'∾∾𝕩} (¬∘(⊣∨»)"-p"⊸≡¨)⊸/•args 
}
