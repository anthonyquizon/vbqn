

runtime ←    •Import "./rt.bqn"     # TODO replace runtime with host runtime - replacement mask with array of cbqn functions
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

init_c ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "a"‿"input"
π
lf←@+10‿13
win←2 # window of lines previous and next to current line

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
  arr← ⊣◶""‿" <"¨(n=l)
  •Out ln←1↓∾lf⊸∾¨(∾⟜"   "∘•Fmt¨l) ∾¨ (src⊏˜l) ∾¨ arr
  •Out ""
}

Breakpoint←{
  src 𝕊 env‿n:
    •Out "Breakpoint!"
    src PrintLines n

    #l←"{𝕊: 100+𝕩} 2"
    #l←"c←10+a ⋄ {𝕊: 100+𝕩} c"
    #l←"c←10+a"
    #l←"b"
    #•Show env
    # TODO inject variables from all parent envs
    #c←⟨runtime, { System 𝕩 }, ⟨"a", "b"⟩⟩ Compile "b"
    # TODO climb parents
    •Show env
    #c←⟨runtime, { System 𝕩 }, ⟨"a", "b"⟩⟩ Compile l
    #c←⟨runtime, { System 𝕩 }, ⟨"a", "b"⟩⟩ Compile "a"
    #•Show { env‿cb‿0‿l VM 𝕩 }⍟(0≠≠c) c
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

    { 𝕊:
      l←Input_c ⟨⟩ # TODO convert utf-8 to Unicode code point
      •Show l
      •Exit⍟(l=0) 0
      #env Eval l
    }•_while_ 1 1
}

Repl @
#src↩•file.Chars "../test/foo.bqn"
##•Show 14⊑runtime
#runtime↩{𝕊:+}¨⌾(0⊸⊏) runtime
#runtime↩{𝕊:↕}¨⌾(14⊸⊏) runtime
#c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
#@‿cb‿3‿src VM c
