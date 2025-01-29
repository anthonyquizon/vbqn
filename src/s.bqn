
#MakeStack ← {
  #s ⇐ 𝕩                                                                                               # Stack (a list)
  #Push ⇐ {s∾↩<𝕩 ⋄ 𝕩}                                                                                  # Push a value
  #Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}                                                                      # Pop 𝕩 values; return as list
  #Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                                                                          # Return but don't pop top value
#}


lf←@+10

bodym ⇐ ⟨⟩ •HashMap ⟨⟩
refm  ⇐ ⟨⟩ •HashMap ⟨⟩
valm  ⇐ ⟨⟩ •HashMap ⟨⟩
filem ⇐ ⟨⟩ •HashMap ⟨⟩


MakeStack ← {
  s ⇐ 𝕩                          # Stack (a list)
  Push ⇐ {s∾↩<𝕩 ⋄ 𝕩}                 # Push a value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s} # Pop 𝕩 values; return as list
  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                # Return but don't pop top value
}

ctx ⇐ {
  s ⇐ MakeStack ⟨⟩

  Push ⇐ { args 𝕊 𝕩:
    f←𝕩∾˜(0⊸≢≠)◶""‿(•ns.Get⟜"cwd") s.Peek @

    Cache←{
      file  ⇐ f
      args  ⇐ args 
      src   ⇐ •file.Chars 𝕩 
      cols  ⇐ ∾+`¨1¨¨⊔+`src=lf
      lines ⇐ 1++`src=lf 
    }
    (filem.Set⟜Cache)⍟(¬∘filem.Has) f
    s.Push { cwd⇐•file.Parent f }
    filem.Get f
  }

  Peek ⇐ s.Peek
  Pop  ⇐ s.Pop
}


bodies⇐{
  s⇐⟨⟩
  Push⇐{ f𝕊i: @ }
  Pop⇐{𝕩}
}

val⇐{
  Rec⇐{𝕩}
}
