⟨⟨Fmt⟩⇐strings⟩←•Import "util.bqn"
lf←@+10

# variables to record
audit ⇐ ⟨⟩
data←⟨⟩
filem←⟨⟩•HashMap⟨⟩
bodym←⟨⟩•HashMap⟨⟩
refm←⟨⟩•HashMap⟨⟩
valm←⟨⟩•HashMap⟨⟩

db←{
  i⇐0
  s⇐0‿3⥊⟨⟩
  Insert⇐{ s (>Fmt¨ i⊸∾¨((𝕨∾'/')⊸∾)⌾⊑¨𝕩)⊸∾↩ ⋄ (i 1⊸+↩) ⊢ i } 
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
  Query←{ 
    db 𝕊 ⟨f,w⟩: db 𝕊 ⟨f,w,⟨⟩⟩
  ; db 𝕊 f‿w‿l: 
    r←Actualize⟜f¨db⊸QueryWhere w 
    r/˜∧´(1⊑¨l) {∨´¨(𝕨)⊸⍷¨𝕩⊸⊑¨r}¨{ ⊑/(⊑𝕩)⊸≡¨f}¨l  # filter 'like' query
  }
}

MakeStack ← {
  s ⇐ 𝕩                                                                                               # Stack (a list)
  Push ⇐ {s∾↩<𝕩 ⋄ 𝕩}                                                                                  # Push a value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s}                                                                      # Pop 𝕩 values; return as list
  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                                                                          # Return but don't pop top value
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

bodies ⇐ {
  s ⇐ MakeStack ⟨⟩
  Push⇐{ file 𝕊 i‿·:
    k←i∾⟨file⟩
    Insert←{ 𝕊:
      id ←(bodym.Count @)
      k bodym.Set id
      "body" db.Insert ⟨"id"‿id, "file"‿file⟩
      id
    }

    id←(bodym.Has)◶Insert‿bodym.Get k
    call← "call" db.Insert ⟨"body"‿id, "depth"‿(≠s.s)⟩
    s.Push {id⇐id ⋄ file⇐file ⋄ call⇐call}
  }

  Pop⇐{ file 𝕊 start‿end: 
    ⟨lines, cols⟩←filem.Get file
    start_line←start⊑lines ⋄ end_line←end⊑lines
    start_col←start⊑cols ⋄ end_col←end⊑cols
    ⟨id⟩←(⊑s.Pop 1) 
    #"body" db.Insert ⟨"bodies/start"‿""⟩
    #db.Exec "update bodies set start_line={}, end_line={}, start_col={}, end_col={} where id={}" Fmt start_line‿end_line‿start_col‿end_col‿id
  }
  Peek⇐s.Peek
}

Ref←{ body‿name 𝕊 file‿i:
  ⟨cols,lines⟩ ← filem.Get file
  line←i⊑lines ⋄ col←i⊑cols
  k←body‿name‿line‿col
  Insert←{ 𝕊:
    #db.Exec "insert into refs(body, name, line, col) values ({}, '{}', {}, {})" Fmt body‿name‿line‿col
    id←db.LastRowId @
    k refm.Set id
    id
  }

  (refm.Has)◶Insert‿refm.Get k
}

val ⇐ {
  Rec⇐{ name‿⟨i,·⟩ 𝕊 v:
    ⟨id,file,call⟩←bodies.Peek @ 
    r← id‿name Ref file‿i

    Cache←{𝕊: n←≠data ⋄ data↩data∾⟨v⟩ ⋄ (𝕩⊸valm.Set)⊸⊢n }
    n← (valm.Has)◶Cache‿valm.Get •Hash v

    #db.Exec "insert into vals(ref, data_index, call, type) values ({}, {}, {}, {})" Fmt r‿n‿call‿(•Type v)
    #@a
  }
}

# TODO post processing
# unique bodies
