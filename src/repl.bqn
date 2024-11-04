⟨⟨Trim⟩⇐strings, ns⟩ ←•Import "util.bqn"
init_c  ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "a"‿"input"

p ← ⟨⟩ •HashMap ⟨⟩ # inspection points

Init_c ⟨⟩
repl←•ReBqn {repl⇐"loose"}

List←{ 𝕩 }
R←{ 𝕩 }

opts←⍉[
  ")l"‿List
  ")r"‿R
]

Run⇐{ 𝕊: { 𝕊:
  l←Input_c ⟨⟩ 

  # run cancel
  •Exit⍟(l=0) 0

  # run opts
  n←≠¨⊏opts ⋄ m←∾n{𝕩⍷𝕨↑l}¨⊏opts ⋄ {f←1⊑𝕩⋄F l}˘m/⍉opts

  # run repl
  {𝕊:Repl ¯2↓l}⍟((0<≠l)∧¬∨´m) @ # drop 2 due to unknown characters
}•_while_ 1 1 }

