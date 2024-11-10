⟨⟨Fmt⟩⇐strings⟩←•Import "util.bqn"
lf←@+10

# variables to record
audit ⇐ ⟨⟩

bodym ⇐ ⟨⟩ •HashMap ⟨⟩
linm  ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines 
colm  ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines
refm  ⇐ ⟨⟩ •HashMap ⟨⟩
valm  ⇐ ⟨⟩ •HashMap ⟨⟩

data←⟨⟩

MakeStack ← {
  s ← 𝕩                          # Stack (a list)
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

  Push ⇐ {
    f←𝕩∾˜(0⊸≢≠)◶""‿⊑ s.Peek @
    s.Push {cwd⇐•file.Parent f, src⇐•file.Chars f, file⇐f}
  }

  Peek ⇐ s.Peek
  Pop  ⇐ s.Pop
}

# Rename?
SetFileLoc⇐{
  𝕊 loc:
    ⟨src,file⟩←ctx.Peek @
    file colm.Set ∾+`¨1¨¨⊔+`src=lf
    file linm.Set 1++`src=lf        # convert locs to line numbers
}

bodies ⇐ {
  s ⇐ MakeStack ⟨⟩

  Push⇐{ 𝕊 i‿·:
    ⟨src,file⟩ ←ctx.Peek @
    k←i∾⟨file⟩

    Insert←{ 𝕊:
      line←i⊑linm.Get file ⋄ col←i⊑colm.Get file  
      id ←(bodym.Count @)
      k bodym.Set id
      sql.Exec "insert into bodies(id, file, line, col) values ({}, '{}', {}, {})" Fmt id‿file‿line‿col
      id
    }

    id←(bodym.Has)◶Insert‿bodym.Get k
    sql.Exec "insert into history(body) values ({})" Fmt id
    s.Push id
  }

  Pop⇐{ 𝕊: (⊑s.Pop 1) }
  Peek⇐s.Peek
}

Ref←{ body‿name 𝕊 file‿i:
  Insert←{ 𝕊:
    line←i⊑linm.Get file ⋄ col←i⊑colm.Get file  
    sql.Exec "insert into refs(body, name, line, col) values ({}, '{}', {}, {})" Fmt body‿name‿line‿col
    id←sql.LastRowId @
    body‿name refm.Set id
    id
  }

  (refm.Has)◶Insert‿refm.Get body‿name
}

Hash←{
  𝕩: 6=•Type 𝕩 ? •Hash 0 # TODO implement
; 𝕩: •Hash 𝕩
}

Rec⇐{ name‿⟨i,·⟩ 𝕊 v:
  ⟨file⟩←ctx.Peek @ ⋄ body←bodies.Peek @ 
  id ← body‿name Ref file‿i

  Cache←{𝕊: n←≠data ⋄ data↩data∾⟨v⟩ ⋄ (𝕩⊸valm.Set)⊸⊢n }
  n← (valm.Has)◶Cache‿valm.Get Hash v

  sql.Exec "insert into vals(ref, i, type) values ({}, {}, {})" Fmt id‿n‿(•Type v)
}

