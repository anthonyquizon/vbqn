engine ← •Import "e.bqn"
⟨sql⟩  ←s← •Import "s.bqn"
repl   ← •Import "repl.bqn"
⟨system, runtime⟩ ← •Import "p.bqn"

sql.Setup @
⟨system, runtime⟩ engine.Run ⊑•args

repl.Run ∾•FLines¨•args/˜»∨´¨"-i"⊸⍷¨•args # -i arguments
