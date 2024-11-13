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

# i32:c8 → i32: the c data type that is converted to and c8: the bqn data type that is converted from
sql⇐{
  sqlite_init_c       ← "../lib.so" •FFI "u64"‿"sqlite_init"‿"*u8:c8"
  sqlite_exec_c       ← "../lib.so" •FFI "u64"‿"sqlite_exec"‿"*u32:c32"
  sqlite_close_c      ← "../lib.so" •FFI ""‿"sqlite_close"
  sqlite_last_rowid_c ← "../lib.so" •FFI "u64"‿"sqlite_last_rowid"

  Init      ⇐ { Sqlite_init_c ⟨𝕩∾@+0⟩     }
  Exec      ⇐ { Sqlite_exec_c ⟨𝕩∾@+0⟩     }
  Close     ⇐ { 𝕊: Sqlite_close_c ⟨⟩      }
  LastRowId ⇐ { 𝕊: Sqlite_last_rowid_c ⟨⟩ }

  Setup ⇐ { 𝕊:
    •SH "rm"‿"-r"‿"_data/db" 
    Init "_data/db"
    Exec •FChars "tables.sql"
  }
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
    ⟨lines, cols⟩←filem.Get file
    k←i∾⟨file⟩

    Insert←{ 𝕊:
      line←i⊑lines ⋄ col←i⊑cols
      id ←(bodym.Count @)
      k bodym.Set id
      sql.Exec "insert into bodies(id, file, line, col) values ({}, '{}', {}, {})" Fmt id‿file‿line‿col
      id
    }

    id←(bodym.Has)◶Insert‿bodym.Get k
    sql.Exec "insert into history(body, depth) values ({}, {})" Fmt id‿(≠s.s)
    s.Push {id⇐id ⋄ file⇐file}
  }

  Pop⇐{ 𝕊: (⊑s.Pop 1) }
  Peek⇐s.Peek
}

Ref←{ body‿name 𝕊 file‿i:
  Insert←{ 𝕊:
    ⟨cols,lines⟩ ← filem.Get file
    line←i⊑lines ⋄ col←i⊑cols
    sql.Exec "insert into refs(body, name, line, col) values ({}, '{}', {}, {})" Fmt body‿name‿line‿col
    id←sql.LastRowId @
    body‿name refm.Set id
    id
  }

  (refm.Has)◶Insert‿refm.Get body‿name
}

#Hash←{
  #𝕩: 6=•Type 𝕩 ? •Hash 0 # TODO implement
#; 𝕩: •Hash 𝕩
#}

Hash←•Hash

Rec⇐{ name‿⟨i,·⟩ 𝕊 v:
  ⟨id,file⟩←bodies.Peek @ 
  r← id‿name Ref file‿i

  Cache←{𝕊: n←≠data ⋄ data↩data∾⟨v⟩ ⋄ (𝕩⊸valm.Set)⊸⊢n }
  n← (valm.Has)◶Cache‿valm.Get Hash v

  sql.Exec "insert into vals(ref, data_index, type) values ({}, {}, {})" Fmt r‿n‿(•Type v)
}

