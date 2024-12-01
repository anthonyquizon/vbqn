⟨⟨Fmt⟩⇐strings, ns⟩ ←•Import "util.bqn"
state←•Import "s.bqn"
init_c  ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "a"‿"input"

p ← ⟨⟩ •HashMap ⟨⟩ # inspection points

Init_c ⟨⟩

List←{ 
  𝕩 
}

Help ← {𝕩 }

Query←{ 
  𝕊: 𝕩
  #•Show "query"‿𝕩
}

History←{ 𝕊:
  𝕩
}

# Repl specific operations
opts←⍉[
  "?"‿Query

  "?h"‿Help
  "?help"‿Help

  "?l"‿List
  "?list"‿List
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

  # get all variables after line in body
  # inject into repl
  # auto complete line fragements

  {𝕊:•Show Repl⎊•CurrentError l}⍟((0<≠l)∧¬∨´m) @ # run repl
}

#Set⇐{ 𝕊 𝕩:
  #repl↩•ReBqn {repl⇐"loose"}
  #n←state.Restore 𝕩
  #{𝕊:
    #l←Input_c ⟨⟩ 
    #•Exit⍟(l=0) 0 # run cancel
    #vars←"⟨{}⟩←2↓•args" Fmt ⟨(1↓∾','⊸∾¨(2↓⊏⍉>n))⟩
    ## TODO drop in line
    #•Show ⟨"","",1⊏⍉>n⟩ Repl "(1⊑•args) { 𝕨 𝕊 𝕩: {} ⋄ {} } ⊑•args" Fmt ⟨vars, l⟩
  #}•_while_ 1 1 
#}

Run⇐{ 
  𝕊 ⟨⟩: 
    { 𝕊:
      l←Input_c ⟨⟩ 
      •Show l
      •Exit⍟(l=0) 0 # run cancel
      Eval l
    }•_while_ 1 1 #@a
; 𝕊 𝕩: Eval¨𝕩
}

