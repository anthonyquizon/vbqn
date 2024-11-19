⟨Import⟩ ← •Import "p.bqn"
conf     ← •Import "conf.bqn"
db←•Import "db.bqn"
repl     ← •Import "r.bqn"

flags←⟨
  conf.SetDebug‿"-g"
⟩

Path←{•wdpath∾"/"∾𝕩}
# TODO consume flag args
#{ 𝕊 f‿i: F¨i⊸(⊢/˜∨´∘⍷¨) •args}¨flags

db.Reset @
db.Setup @
Import ⊑Path¨•args
#repl.Run ∾•FLines¨"-i"(⊢/˜⊣⊸»∘∨´∘⍷¨)•args

repl.Set ⟨⟩
repl.Run ⟨⟩

