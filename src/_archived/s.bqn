db←•Import "d.bqn"
⟨⟨Fmt⟩⇐strings⟩←•Import "u.bqn"
lf←@+10

# variables to record
audit ⇐ ⟨⟩
filem←⟨⟩•HashMap⟨⟩
bodym←⟨⟩•HashMap⟨⟩
refm ←⟨⟩•HashMap⟨⟩
valm ←⟨⟩•HashMap⟨⟩
data ←⟨⟩


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
    "body_bounds" db.Insert ⟨
      "body"‿id, 
      "start_line"‿start_line, "end_line"‿end_line
      "start_col"‿start_col,   "end_col"‿end_col
    ⟩
  }
  Peek⇐s.Peek
}

Ref←{ body‿name 𝕊 file‿i:
  ⟨cols,lines⟩ ← filem.Get file
  line←i⊑lines ⋄ col←i⊑cols
  k←body‿name‿line‿col
  Insert←{ 𝕊:
    id←"refs" db.Insert ⟨"body"‿body, "name"‿name, "line"‿line, "col"‿col⟩
    k refm.Set id ⋄ id
  }
  (refm.Has)◶Insert‿refm.Get k
}

val ⇐ {
  Rec⇐{ name‿⟨i,·⟩ 𝕊 v:
    ⟨id,file,call⟩←bodies.Peek @ 
    ref← id‿name Ref file‿i
    Cache←{𝕊: n←≠data ⋄ data↩data∾⟨v⟩ ⋄ (𝕩⊸valm.Set)⊸⊢n }
    index← (valm.Has)◶Cache‿valm.Get •Hash v
    "vals" db.Insert ⟨"ref"‿ref, "index"‿index, "call"‿call, "type"‿(•Type v)⟩
  }
}
