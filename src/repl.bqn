⟨⟨Trim⟩⇐strings, ns⟩ ←•Import "util.bqn"
init_c  ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "a"‿"input"

p ← ⟨⟩ •HashMap ⟨⟩ # inspection points

Init_c ⟨⟩
repl←•ReBqn {repl⇐"loose"}

Eval ← {
  ")l": "wo"
}

Run⇐{ 
  𝕊 opts:
    { 𝕊:
      l←Input_c ⟨⟩ 
      •Exit⍟(l=0) 0
      Eval •Show Trim l
      #Repl l
    }•_while_ 1 1
}
