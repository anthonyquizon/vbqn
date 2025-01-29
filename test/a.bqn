# ⟨⟨a₁,a₂,...aₙ⟩, ⟨⟩⟩ Foo ⟨b₁,b₂...b₄⟩ → ⟨a₁+b₁, a₂+b₂, ...aₙ+bₙ⟩
Foo←{
   𝕊 c: c+1 #?
;𝕨 𝕊 c: 𝕨+1 #? "{} {}" •_Fmt c‿b‿
}

•Show Foo 1
