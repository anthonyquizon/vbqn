
runtime ←    •Import "./rt.bqn"     
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

init_c ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "i32"‿"input"‿">&u8:c8"

lf←@+10‿13
win←2

src←@

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
  src 𝕊 env:
    •Out "Breakpoint!"
    #PrintLines src
    buf←' '¨↕1024

    •Show env
    c←⟨runtime, { System 𝕩 }, ⟨"a", "b"⟩⟩ Compile "b"
    •Show { env‿cb‿0‿"a"‿1 VM 𝕩 }⍟(0≠≠c) c
    #{ 𝕊:
      #r‿l←Input_c buf
      #•Exit⍟(¬r) r
      #l↩{⟨⟩:"";l↑˜⊑𝕩}/l=@+0

    #}•_while_ 1 1
}

cb←{Breakpoint⇐Breakpoint} # callbacks

# TODO line /character positions
Catch←{𝕊: •Out "Error: " ∾ •Fmt •CurrentError @ ⋄ ⟨⟩}

Eval ←{
       · 𝕊 ⟨⟩ : ⟨⟩
  ;  env 𝕊 𝕩 : 𝕩≡")r" ? 
      •Out "Running program"
      c ← ⟨runtime, { System 𝕩 }⟩ Compile src
      env‿cb‿3‿src VM c
  ; env 𝕊 l:
    # TODO merge env
    #FIXME cleanup
    c←{ ⟨runtime, { System 𝕩 }⟩ Compile 𝕩 }⎊Catch l
    •Show { env‿cb‿@‿l VM 𝕩 }⍟(0≠≠c) c
}

# f: file
# TODO repl history
Repl ⇐ {
  𝕊 env:
    Init_c ⟨⟩
    buf←' '¨↕1024
    { 𝕊:
      r‿l←Input_c buf # TODO convert utf-8 to Unicode code point
      π
      •Exit⍟(¬r) r
      •SHow l-@
      l↩{⟨⟩:"";l↑˜⊑𝕩}/l=@+0
      env Eval l
    }•_while_ 1 1
}

#•SHow VM (⟨runtime, { System 𝕩 }⟩⊸Compile) "π"

#env←{vars⇐⟨⟩, program⇐{consts⇐⟨⟩ ⋄ blocks⇐⟨⟩ ⋄ names⇐⟨⟩} }
#c←⟨runtime, { System 𝕩 }⟩ Compile "π"
#•Show env‿⟨⟩‿⟨⟩‿"@" VM c
#Init_c ⟨⟩
#env←{vars⇐⟨⟩, program⇐{consts⇐⟨⟩ ⋄ blocks⇐⟨⟩ ⋄ names⇐⟨⟩} }
#env Eval ")r"
#Repl {vars⇐⟨⟩, program⇐{consts⇐⟨⟩ ⋄ blocks⇐⟨⟩ ⋄ names⇐⟨⟩} }
#GetLine @
#•Show 

src↩•file.Chars "../test/foo.bqn"
env←{vars⇐⟨⟩, program⇐{consts⇐⟨⟩ ⋄ blocks⇐⟨⟩ ⋄ names⇐⟨⟩} }
#env←{vars⇐⟨"a"⟩, program⇐{consts⇐⟨⟩ ⋄ blocks⇐⟨⟩ ⋄ names⇐⟨⟩} }
c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
# get all vars from env
# add byte code instructions to push
env‿cb‿3‿src‿0 VM c
#•SHow c

#c0 ← ⟨runtime, { System 𝕩 }, ⟨"a"⟩⟩ Compile "a"
#•Show env‿cb‿9‿src VM c
## TODO see how variables are referenced at the end of a program
#•SHow c0
#•Out "Running program"
#c ← ⟨runtime, { System 𝕩 }⟩ Compile src
#env‿cb‿3‿src VM c
