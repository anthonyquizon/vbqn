#bar ← •Import "bar.bqn"
a←111
b←222

F←{ 𝕊: 𝕩+a }
G←{ 𝕊: 𝕩+b }

F a
G b
F b
