engine ← •Import "./e.bqn"

system⇐@
runtime⇐⟨
 +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,⋈,↑,↓,↕,«,»,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!,
 ˙,˜,˘,¨,⌜,⁼,´,˝,`,
 ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟,⎊,
⟩

import_cache←⟨⟩ •HashMap ⟨⟩ #cached imported files

Import ← {
  import_cache.Has 𝕩 ? import_cache.Get 𝕩;
  𝕩 : 
    r←⟨system, runtime⟩ engine.Run 𝕩
    𝕩 import_cache.Set r
    r
}
# Lookup table
systable← ∾<˘⋈˘⍉>⟨
    "type"‿•Type
     "out"‿•Out
    "show"‿•Show
  "import"‿Import
⟩

FindSys ← {
  i ← 𝕨⊐𝕩
  { ! ∾⟨"Unknown system value",(1≠≠𝕩)/"s",":"⟩∾" •"⊸∾¨𝕩 }∘/⟜𝕩⍟(∨´) i=≠𝕨
  i
}

system↩{ 𝕨⊸FindSys⊏𝕩˙ }´systable

