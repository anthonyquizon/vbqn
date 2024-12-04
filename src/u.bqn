strings⇐{
  IsStr←(0=•Type)◶⟨0, 1∧´2=•Type¨⟩

  n←1000000
  FmtNum ⇐ { (0⊸≤)◶⟨'-'⊸∾∘•Fmt|,•Fmt⟩(⌊0.5⊸+)⌾((10⋆4)⊸×)(-n)⌈n⌊𝕩}  # formats number eg. ¯9.999999 to -9.99
  FmtStr⇐Str⇐(2⌊•Type)◶⟨{1∧´2=•Type¨𝕩 ? 𝕩; •Fmt 𝕩},FmtNum,≍⟩

  Fmt ⇐ { 
      𝕊 𝕩: Str¨𝕩    
  ;ch 𝕊 𝕩: 6≡•Type 𝕩 ?                                             # named replacement values
      s‿e←ch⊸=¨"{}" ⋄ f←(+`s+»e)⊸⊔ch                               # fragments
      m←f∊t←{'{'∾𝕩∾'}'}¨k←•ns.Keys 𝕩                               # k: keys, t: tags
      v←Str¨(m/t⊐f)⊸⊏ (𝕩 •ns.Get¨k)                                # v: replacement values
      ∾v⌾(m⊸/) f
  ;ch 𝕊 𝕩:                                                         # unnamed replacement values
      s‿e←ch⊸=¨"{}" ⋄ f←(+`s+»e)⊸⊔ch                               # fragments
      m←∾('}'=¯1↑¨f)∧'{'=1↑¨f
      t←m/f                                                        # tags
      v←Str¨(≠t)↑𝕩∾⟨⟩¨↕0⌈(≠t)-(≠𝕩)                                 # replacement values
      ∾v⌾(m⊸/)f
  }

  Trim⇐((∨`∧∨⟜«)' '⊸≠)⊸/

  # String similarity (From bqn-libs)
  LcsLen ← ∧○(0<≠)◶⟨0, ¯1 ⊑ 0¨∘⊢ {𝕩⌈⌈`𝕨+»𝕩}˝ =⌜⟜⌽⟩
  Lcs ← ¯1 ⊑ "" <⊸∾ ""¨∘⊢ ⊣⍟(>○≠){𝕩𝔽¨𝔽`𝕨∾¨""<⊸»𝕩}˝ (=⌜⥊¨⊣)⟜⌽
  Levenshtein ← ¯1⊑{𝕨((1⊸+⥊+)○≠(⌊`⊢⌊⊏⊸»∘⊢-0∾1+=⟜𝕩)´⌽∘⊣)𝕩}
}

### Namespaces

ns⇐{
  # default 𝕊 namespace‿key
  Opt⇐{ 
    d 𝕊 n‿·: 6≢•Type n ? d;
    d 𝕊 n‿k: (•ns.Has⟜k)◶d‿(•ns.Get⟜k) n 
  }
}

## Loggings -- TODO delete dogfood instead
Debug⇐{•Out 𝕨∾": "∾•Fmt 𝕩 }⍟conf.debug
