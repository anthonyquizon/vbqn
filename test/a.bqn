# ⟨⟨a₁,a₂,...aₙ⟩, ⟨⟩⟩ Foo ⟨b₁,b₂...b₄⟩ → ⟨a₁+b₁, a₂+b₂, ...aₙ+bₙ⟩ | a∊Char b∊Num
# ⟨x | x>|x|⟩

Foo←{
   𝕊 c: c+1 #? # prints all variables assigned/used on line
;𝕨 𝕊 c: 𝕨+1 #? ⟨a‿b‿c⟩ # subset 
}

•Show Foo ↕10
