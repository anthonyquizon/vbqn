⟨Import⟩ ← •Import "p.bqn"
⟨sql⟩  ←s← •Import "s.bqn"
repl   ← •Import "repl.bqn"

sql.Setup @
Import ⊑•args

repl.Run ∾•FLines¨•args/˜»∨´¨"-i"⊸⍷¨•args # -i arguments
