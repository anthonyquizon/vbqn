⟨Run⟩    ← •Import "p.bqn"
conf     ← •Import "conf.bqn"
s        ← •Import "s.bqn"

{ 𝕊: •Out "Missing input file" ⋄ •Exit 1 }⍟(0=≠) •args

Path←{•wdpath∾"/"∾𝕩}

s.db.Reset @
s.db.Setup @

Run ⊑Path¨•args
input← •FLines "/dev/fd/0"
•SHow¨input

