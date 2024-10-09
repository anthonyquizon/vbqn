
runtime ←    •Import "./rt.bqn"     
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

init_c ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "i32"‿"input"‿">&u8:c8"

lf←@+10‿13
win←2

# Lookup table
systable←⟨
  "type"‿"out"‿"show"
  •Type ‿•Out ‿•Show 
⟩

  # Lookup table
FindSys ← {
  i ← 𝕨⊐𝕩
  { ! ∾⟨"Unknown system value",(1≠≠𝕩)/"s",":"⟩∾" •"⊸∾¨𝕩 }∘/⟜𝕩⍟(∨´) i=≠𝕨
  i
}
system ← {𝕨⊸FindSys⊏𝕩˙}´systable

PrintLines ← { src 𝕊 n:
  l←∾⟨¯1↓⌽n-↕win,n+↕win⟩
  l↩l/˜(l≥0)∧l<≠src
  arr← ⊣◶""‿" <--"¨(n=l)
  •Out ln←1↓∾lf⊸∾¨(∾⟜"   "∘•Fmt¨l) ∾¨ (src⊏˜l) ∾¨ arr
  •Out ""
}


Breakpoint←{
  𝕨 𝕊 env:
    •Out "Breakpoint!"
    buf←' '¨↕1024
    { 𝕊:
      r‿l←Input_c buf
      l↩{⟨⟩:"";l↑˜⊑𝕩}/l=@+0
      env Eval l
      r
    }•_while_ ⊢ 1
}

# TODO line /character positions
Catch←{𝕊: •Out "Error: " ∾ 1⊑•CurrentError @ ⋄ ⟨⟩}

Eval ←{
       · 𝕊 ⟨⟩ : ⟨⟩
  ;  src 𝕊 𝕩 : 𝕩≡")r" ? 
      •Out "Running program"
      c ← ⟨runtime, { System 𝕩 }⟩ Compile src
      {Breakpoint⇐Breakpoint}‿2‿src VM c
  ; · 𝕊 𝕩 :
    #FIXME cleanup
    c←{ ⟨runtime, { System 𝕩 }⟩ Compile 𝕩 }⎊Catch 𝕩
    {𝕊: {•SHow VM 𝕩}⎊Catch c}⍟(0≠≠c) @
}

# f: file
# TODO repl history
Repl ⇐ {
  𝕊 f:
    src←•file.Chars f
    Init_c ⟨⟩
    buf←' '¨↕1024
    { 𝕊:
      r‿l←Input_c buf
      l↩{⟨⟩:"";l↑˜⊑𝕩}/l=@+0
      src Eval l
      r
    }•_while_ ⊢ 1
}


#•SHow VM (⟨runtime, { System 𝕩 }⟩⊸Compile) "1+1"
Repl "../test/foo.bqn"
#GetLine @
#•Show 
