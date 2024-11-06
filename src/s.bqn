⟨⟨Fmt⟩⇐strings, ⟨Update⟩⇐hashmap⟩←•Import "util.bqn"
lf←@+10

# variables to record
audit ⇐ ⟨⟩

idm   ⇐ ⟨⟩ •HashMap ⟨⟩
linm  ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines 
colm  ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines
datm  ⇐ ⟨⟩ •HashMap ⟨⟩ # data map

#do_reg←1 # if registration phase has completed

#Start ⇐ { 𝕊: 1 }
#End   ⇐ { 𝕊: do_reg↩0 }

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
    s.Push {cwd⇐•file.Parent f, src⇐•file.Chars "../"∾f, file⇐f}
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
  c ⇐ 0

  Push⇐{
    start‿·←𝕩
      ⟨src,file⟩ ←ctx.Peek @
      id←idm‿(start∾⟨file⟩) Update (idm.Count @)
      c +⟜1↩

      sql.Exec "insert or replace into bodies(id, start, file) values ({}, {}, '{}')" Fmt id‿start‿file
      sql.Exec "insert into history(body) values ({})" Fmt id
      s.Push id
  }

  Pop⇐{ 𝕊: (⊑s.Pop 1) }
  Peek⇐s.Peek
}

Reg←{ body‿name‿file‿i:
  l←i⊑linm.Get file ⋄ c←i⊑colm.Get file  
  sql.Exec "insert or replace into vars(body, name, line, col) values ({}, '{}', {}, {})" Fmt body‿name‿l‿c
  sql.LastRowId @
}


## TODO rec arr shape/min/max/function query value

Rec⇐{ name‿⟨i,·⟩ 𝕊 v:
  ⟨file⟩←ctx.Peek @ ⋄ body←bodies.Peek @ 
  id← Reg body‿name‿file‿i
  id datm.Set v
}

