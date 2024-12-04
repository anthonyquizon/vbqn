
#MakeStack ← {
  #s ⇐ 𝕩                                                                                               # Stack (a list)
  #Push ⇐ {s∾↩<𝕩 ⋄ 𝕩}                                                                                  # Push a value
  #Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}                                                                      # Pop 𝕩 values; return as list
  #Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                                                                          # Return but don't pop top value
#}


db←d←t←⟨⟩ #
bs‿bf←↕2 # body/start‿body/file

bodies⇐{
  s⇐⟨⟩
  Push⇐{ f𝕊i: 
    ri‿rf←⊑(⊣⊐˜{d↩⍷d∾𝕩})⋈f
    db↩⟨i‿bs‿ri, i‿bf‿rf⟩⊣i←≠db

  }
}
