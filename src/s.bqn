
MakeStack ← {
  s ← 𝕩                          # Stack (a list)
  Push ⇐ {s∾↩<𝕩 ⋄ 𝕩}                 # Push a value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s} # Pop 𝕩 values; return as list
  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                # Return but don't pop top value
}

ctx⇐MakeStack ⟨⟩

Push⇐{
  f←𝕩∾˜(0⊸≢≠)◶""‿⊑ ctx.Peek 1
  ctx.Push ⟨•file.Parent "../"∾f, •file.Chars "../"∾f, f⟩
  # TODO push line?
}

Pop⇐{ 𝕊:ctx.Pop 1 }

