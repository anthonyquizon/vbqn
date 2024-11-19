db←•Import "db.bqn"
⟨⟨Fmt⟩⇐strings⟩←•Import "util.bqn"
lf←@+10

# variables to record
audit ⇐ ⟨⟩

bodym ⇐ ⟨⟩ •HashMap ⟨⟩
refm  ⇐ ⟨⟩ •HashMap ⟨⟩
valm  ⇐ ⟨⟩ •HashMap ⟨⟩
filem ⇐ ⟨⟩ •HashMap ⟨⟩

data←⟨⟩

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

#trace ⇐ {
  #s ⇐ MakeStack ⟨⟩
  #f⇐@

  #Set ⇐ {
    #𝕊 loc:
      #⟨col⟩←ctx.Peek @
      #f↩loc
  #}

  #Push ⇐ { 𝕊: s.Push f }
  #Pop  ⇐ s.Pop
#}

bodies ⇐ {
  s ⇐ MakeStack ⟨⟩

  Push⇐{ file 𝕊 i‿·:
    k←i∾⟨file⟩

    Insert←{ 𝕊:
      id ←(bodym.Count @)
      k bodym.Set id
      db.Exec "insert into bodies(id, file) values ({}, '{}')" Fmt id‿file
      id
    }

    id←(bodym.Has)◶Insert‿bodym.Get k
    db.Exec "insert into calls(body, depth) values ({}, {})" Fmt id‿(≠s.s)
    call←db.LastRowId @
    s.Push {id⇐id ⋄ file⇐file ⋄ call⇐call}
  }

  Pop⇐{ file 𝕊 start‿end: 
    ⟨lines, cols⟩←filem.Get file
    start_line←start⊑lines ⋄ end_line←end⊑lines
    start_col←start⊑cols ⋄ end_col←end⊑cols
    ⟨id⟩←(⊑s.Pop 1) 
    db.Exec •Show "update bodies set start_line={}, end_line={}, start_col={}, end_col={} where id={}" Fmt start_line‿end_line‿start_col‿end_col‿id
  }
  Peek⇐s.Peek
}

Ref←{ body‿name 𝕊 file‿i:
  ⟨cols,lines⟩ ← filem.Get file
  line←i⊑lines ⋄ col←i⊑cols
  k←body‿name‿line‿col
  Insert←{ 𝕊:
    db.Exec "insert into refs(body, name, line, col) values ({}, '{}', {}, {})" Fmt body‿name‿line‿col
    id←db.LastRowId @
    k refm.Set id
    id
  }

  (refm.Has)◶Insert‿refm.Get k
}

Hash←•Hash

val ⇐ {
  Rec⇐{ name‿⟨i,·⟩ 𝕊 v:
    ⟨id,file,call⟩←bodies.Peek @ 
    r← id‿name Ref file‿i

    Cache←{𝕊: n←≠data ⋄ data↩data∾⟨v⟩ ⋄ (𝕩⊸valm.Set)⊸⊢n }
    n← (valm.Has)◶Cache‿valm.Get Hash v

    db.Exec "insert into vals(ref, data_index, call, type) values ({}, {}, {}, {})" Fmt r‿n‿call‿(•Type v)
  }
}

sys⇐{
  Rec⇐{ 𝕊: 
    # TODO
    𝕩
  }
}

Restore⇐{
  acc←⟨⟩

  { acc↩acc∾⟨𝕩⟩ ⋄ 0 } db._Query "
      select name, vals.data_index from refs 
        inner join calls on vals.call=calls.id 
        inner join vals on vals.ref = refs.id 
        inner join bodies 
        where   
            refs.line >= bodies.start_line  and 
            refs.line <= {}                 and 
            calls.id={}
        group by 
            refs.name
  " Fmt 𝕩

  {·‿i: •SHow i}¨acc
  {·‿i: i⊑data}¨acc
}
