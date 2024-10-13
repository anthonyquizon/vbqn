
runtime ←    •Import "./rt.bqn"     
gl      ←    •Import "./glyphs.bqn"
compile ← gl •Import "./c.bqn"
vm      ←    •Import "./vm.bqn"

init_c ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "i32"‿"input"‿">&u8:c8"

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
    buf←' '¨↕1024

    #l←"{𝕊: 100+𝕩} 2"
    l←"{𝕊: 100+𝕩} a"
    #l←"b"
    #•Show env
    # TODO inject variables from all parent envs
    #c←⟨runtime, { System 𝕩 }, ⟨"a", "b"⟩⟩ Compile "b"
    c←⟨runtime, { System 𝕩 }, ⟨"a", "b"⟩⟩ Compile l
    #c←⟨runtime, { System 𝕩 }, ⟨"a", "b"⟩⟩ Compile "a"
    •Show { env‿cb‿0‿l VM 𝕩 }⍟(0≠≠c) c
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
      •Exit⍟(¬r) r
      # TODO unicode conversion
      l↩{⟨⟩:"";l↑˜⊑𝕩}/l=@+0
      env Eval l
    }•_while_ 1 1
}

src↩•file.Chars "../test/foo.bqn"
c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
@‿cb‿3‿src VM c
