
i⇐0 ⋄ s⇐0‿3⥊⟨⟩ ⋄ n←⟨⟩ ⋄ d←⟨⟩
Insert⇐{ 
  •Show 𝕩
  # TODO if not in n or d - add and return index-1
  •Show i⊸∾¨𝕩{(•SHow 𝕨)⊸≡¨𝕩}¨n‿d ⋄ (i 1⊸+↩) ⊢ i 
} 
MatchVar ←{ c 𝕊 v‿t: (∨´)◶{𝕊:c∾˘[⟨v⟩,⟨t⟩]}‿{c MatchPart (⊑𝕩/1⊏c)‿t} ⟨v⟩⍷⊏c }
MatchPart←{
 @ 𝕊 ·   : @
;c 𝕊 p‿t: '?'=⊑ p ? c MatchVar p‿t                                                                  #@a
;c 𝕊 p‿t: p≡t ? c
;· 𝕊 ·  : @
}
MatchPattern←{ c 𝕊 p‿t: c MatchPart˜´ p⋈¨t }
QuerySingle ←{ c 𝕊 p‿db: (⊣/˜@⊸≢¨){ c MatchPattern p‿𝕩 }¨<˘db }
QueryWhere ←{ 𝕊 p‿db: ⟨[⟨⟩,⟨⟩]⟩ {∾(QuerySingle⟜(𝕨‿db))¨𝕩}´p }
Actualize←{ c←𝕨 ⋄ m←('?'=⊑)¨𝕩 ⋄ {(1⊏c)⊏˜𝕩⊐˜⊏c}⌾(m⊸/) 𝕩 }
Query⇐{ 
  db 𝕊 ⟨f,w⟩: db 𝕊 ⟨f,w,⟨⟩⟩
; db 𝕊 f‿w‿l: 
  r←Actualize⟜f¨db⊸QueryWhere w 
  r/˜∧´(1⊑¨l) {∨´¨(𝕨)⊸⍷¨𝕩⊸⊑¨r}¨{ ⊑/(⊑𝕩)⊸≡¨f}¨l  # filter 'like' query
}

Insert ⟨"body/foo"‿123, "body/bar"‿234⟩
#•SHow s

