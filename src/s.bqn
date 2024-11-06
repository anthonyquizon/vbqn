⟨⟨Fmt⟩⇐strings, ⟨Update⟩⇐hashmap⟩←•Import "util.bqn"
lf←@+10

# data map

idm   ⇐ ⟨⟩ •HashMap ⟨⟩
linm  ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines 
colm  ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines

MakeStack ← {
  s ← 𝕩                          # Stack (a list)
  Push ⇐ {s∾↩<𝕩 ⋄ 𝕩}                 # Push a value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s} # Pop 𝕩 values; return as list
  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                # Return but don't pop top value
}

# i32:c8 → i32: the c data type that is converted to and c8: the bqn data type that is converted from
sql⇐{
  sqlite_init_c  ← "../lib.so" •FFI "u64"‿"sqlite_init"‿"*u8:c8"
  sqlite_exec_c  ← "../lib.so" •FFI "u64"‿"sqlite_exec"‿"*u32:c32"
  sqlite_close_c ← "../lib.so" •FFI ""‿"sqlite_close"

  Init  ⇐ { Sqlite_init_c ⟨𝕩∾@+0⟩ }
  Exec  ⇐ { Sqlite_exec_c ⟨𝕩∾@+0⟩ }
  Close ⇐ { 𝕊: Sqlite_close_c ⟨⟩ }

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
    file linm.Set 1++`src=lf # convert locs to line numbers
}

bodies ⇐ {
  s⇐ MakeStack ⟨⟩
  c ⇐ 0

  Push⇐{
    start‿·←𝕩
      ⟨src,file⟩ ←ctx.Peek @
      id←idm‿(start∾⟨file⟩) Update (idm.Count @)
      c +⟜1↩

      sql.Exec "insert into bodies(id, start, file) values ({}, {}, '{}')" Fmt id‿start‿file
      # TODO add history
      s.Push id
  }

  Pop⇐{ 𝕊: (⊑s.Pop 1) }

  Reg⇐{ name 𝕊 i‿·:
    ⟨file⟩←ctx.Peek @ 
    id←s.Peek @ ⋄ l←i⊑linm.Get file ⋄ c←i⊑colm.Get file  
    
    sql.Exec "insert into regs(body, name, line, col) values ({}, '{}', {}, {})" Fmt id‿name‿l‿c

  }
}
