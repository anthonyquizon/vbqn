#! /usr/bin/env bqn

engine ← •Import "./src/e.bqn"
⟨sql⟩ ← •Import "./src/s.bqn"
⟨system, runtime⟩ ← •Import "./src/p.bqn"
⟨system, runtime⟩ engine.Run ⊑•args

sql.Populate @
