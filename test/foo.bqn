#bar ← •Import "bar.bqn"
#a←↕10
#b←3+a
#bar.a + b + a

z←111

# ⟨a,b,c,...⟩ 𝕊 ⟨a,b,c,d,...⟩ → ⟨a,b⟩
F←{
  𝕊: 𝕩+z 
}

F 1
