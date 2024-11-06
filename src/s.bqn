⟨⟨Fmt⟩⇐strings⟩←•Import "util.bqn"

varm    ⇐ ⟨⟩ •HashMap ⟨⟩ # variables and arguments
regm    ⇐ ⟨⟩ •HashMap ⟨⟩ # 
valm    ⇐ ⟨⟩ •HashMap ⟨⟩ # 
idm     ⇐ ⟨⟩ •HashMap ⟨⟩
outm    ⇐ ⟨⟩ •HashMap ⟨⟩
linem   ⇐ ⟨⟩ •HashMap ⟨⟩
bodiesm ⇐ ⟨⟩ •HashMap ⟨⟩
linesm  ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines 
colsm   ⇐ ⟨⟩ •HashMap ⟨⟩ # file -> bytcode to lines 
history ⇐ ⟨⟩

lf←@+10

# TODO function names
# TODO variable names from ids

MakeStack ← {
  s ← 𝕩                          # Stack (a list)
  Push ⇐ {s∾↩<𝕩 ⋄ 𝕩}                 # Push a value
  Pop  ⇐ {t←-𝕩 ⋄ (s↓˜↩t) ⊢ ⌽t↑s} # Pop 𝕩 values; return as list
  Peek ⇐ {𝕊: 0=≠s ? ⟨⟩;¯1⊑s}                # Return but don't pop top value
}

ctx ⇐ {
  s ⇐ MakeStack ⟨⟩

  Push ⇐ {
    f←𝕩∾˜(0⊸≢≠)◶""‿⊑ s.Peek @
    src←•file.Chars "../"∾f
    s.Push ⟨•file.Parent f, src, f⟩
  }

  Peek ⇐ s.Peek
  Pop  ⇐ s.Pop
}

Update ← { m‿k 𝕊 f: m.Has◶{v←F @ ⋄𝕩 m.Set v ⋄ v}‿m.Get k }

# Rename?
SetFileLoc⇐{
  𝕊 loc:
    ⟨·,src,file⟩ ←ctx.Peek @
    file colsm.Set ∾+`¨1¨¨⊔+`src=lf
    file linesm.Set 1++`src=lf # convert locs to line numbers
}

# Hash: start‿filename‿c
bodies ⇐ {
  s⇐ MakeStack ⟨⟩

  Push⇐{
    start‿args←𝕩
      ⟨·,src,file⟩ ←ctx.Peek @
      id←idm‿(start∾⟨file⟩) Update (idm.Count @)
      history ∾⟜(⟨id⟩)↩
      s.Push id
  }

  Pop⇐{ (⊑s.Pop 1) outm.Set 𝕩 }

  Rec⇐{
    l 𝕊 v: 
      id ←s.Peek @ ⋄ i←1-˜≠history
      (i‿id‿l) varm.Set v
  }

  # register variable location
  Reg⇐{
    name 𝕊 l:
      •SHow name‿l
      ⟨·,·,file⟩ ←ctx.Peek @ 
      id ←s.Peek @
      ln←(⊑l)⊑linesm.Get file # lines
      cs←l⊏colsm.Get file     # columns
      (id‿name) regm.Set cs∾ln
  }
}


# i32:c8 → i32: the c data type that is converted to and c8: the bqn data type that is converted from
sql⇐{
  sqlite_init_c  ← "../lib.so" •FFI "u64"‿"sqlite_init"‿"*u8:c8"
  sqlite_exec_c  ← "../lib.so" •FFI "u64"‿"sqlite_exec"‿"*u32:c32"
  sqlite_close_c ← "../lib.so" •FFI ""‿"sqlite_close"

  Init  ⇐ { Sqlite_init_c ⟨𝕩∾@+0⟩ }
  Exec  ⇐ { Sqlite_exec_c ⟨𝕩∾@+0⟩ }
  Close ⇐ { 𝕊: Sqlite_close_c ⟨⟩ }
  Populate ⇐ { 𝕊:
    #"v"‿"out"‿"idm"{•Show 𝕨 ⋄ •Show >(𝕩.Keys @)‿(𝕩.Values @)}¨varm‿outm‿idm

    •SH "rm"‿"-r"‿"_data/db"

    sql.Init "_data/db"
    sql.Exec •FChars "tables.sql"

    # insert body info
    (idm.Keys@) {
      start‿filename 𝕊 id:
        sql.Exec "insert into bodies(id, start, filename) values ({}, {}, '{}')" Fmt id‿start‿filename
    }¨idm.Values @

    # insert variables
    # TODO insert indices
    #(varm.Keys @){ 
      #call‿id‿name 𝕊 val:
        #sql.Exec "insert into vars(body, call, name, value, reified) values ({}, {}, '{}', '{}', true)" Fmt id‿call‿name‿(•Fmt val)
    #} ¨•Fmt¨varm.Values @

    (regm.Keys @){ 
      id‿name 𝕊 col_s‿col_e‿line:
        sql.Exec "insert into regs(body, name, col_s, col_e, line) values ({}, '{}', {}, {}, {})" Fmt id‿name‿col_s‿col_e‿line
    } ¨regm.Values @

    # insert history
    { sql.Exec "insert into history(body) values ({})" Fmt ⟨𝕩⟩ } ¨history
  }
}

