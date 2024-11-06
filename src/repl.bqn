⟨⟨Trim⟩⇐strings, ns⟩ ←•Import "util.bqn"
s ←•Import "s.bqn"
init_c  ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "a"‿"input"

p ← ⟨⟩ •HashMap ⟨⟩ # inspection points

Init_c ⟨⟩

List←{ 
  𝕩 
}

Help ← {𝕩 }

Query←{ 
  •Show "query"‿𝕩
}

# HACK
History←{ 𝕊:
  k←s.idm.Keys @
  v←s.idm.Values @
  •Show s.history
  #•Show { i‿f: 20↑i↓ •FChars "../"∾f }¨k⊏˜v⊏s.history
}

# Repl specific operations
opts←⍉[
  ")h"‿Help
  ")help"‿Help

  ")l"‿List
  ")list"‿List
  #")r"‿R
  # TODO explain
]

system←⟨
  "show"‿•Show, 
  "query"‿Query, "q"‿Query,
  "history"‿History, "h"‿History
⟩

repl← •ReBqn {repl⇐"loose"⋄ system⇐system}

Eval ← { 𝕊 l:
  n←≠¨⊏opts ⋄ m←∾n{𝕩⍷𝕨↑l}¨⊏opts ⋄ {f←1⊑𝕩⋄F l}˘m/⍉opts # run opts eg. )l
  {𝕊:•Show Repl⎊•CurrentError l}⍟((0<≠l)∧¬∨´m) @ # run repl
}

Run⇐{ 
  𝕊 ⟨⟩: 
    { 𝕊:
      l←Input_c ⟨⟩ 
      •Exit⍟(l=0) 0 # run cancel
      Eval l
    }•_while_ 1 1 
; 𝕊 𝕩: Eval¨𝕩
}

