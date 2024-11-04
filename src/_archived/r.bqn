
init_c ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "a"‿"input"
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

cb←@ # TODO delete
# TODO line /character positions
Catch←{𝕊: •Out "Error: " ∾ •Fmt •CurrentError @ ⋄ ⟨⟩}

# f: file
# TODO repl history
Repl ⇐ {
  𝕊 env:
    Init_c ⟨⟩

    F←•ReBqn {repl⇐"loose"}
    # TODO load data
    { 𝕊:
      l←Input_c ⟨⟩ # TODO convert utf-8 to Unicode code point
      •Exit⍟(l=0) 0
      F l
      #env Eval l
    }•_while_ 1 1
}

Repl @

# TODO query sql
  # if none reified: 
    # run functions with call values again


#src↩•file.Chars "../test/foo.bqn"
###•Show 14⊑runtime
##runtime↩{𝕊:+}¨⌾(0⊸⊏) runtime
##runtime↩{𝕊:↕}¨⌾(14⊸⊏) runtime
#c ← ⟨runtime, { System 𝕩 }, ⟨⟩⟩ Compile src
#@‿cb‿3‿src VM c
