⟨⟨Fmt⟩⇐strings⟩←•Import "util.bqn"
lf←@+10

# variables to record
audit ⇐ ⟨⟩

bodym ⇐ ⟨⟩ •HashMap ⟨⟩
refm  ⇐ ⟨⟩ •HashMap ⟨⟩
valm  ⇐ ⟨⟩ •HashMap ⟨⟩
filem ⇐ ⟨⟩ •HashMap ⟨⟩

data←⟨⟩

db⇐{
  sqlite_init_c       ← "../lib.so" •FFI "u64"‿"sqlite_init"‿"*u8:c8"
  sqlite_exec_c       ← "../lib.so" •FFI "u64"‿"sqlite_exec"‿"*u32:c32"‿"a"
  sqlite_close_c      ← "../lib.so" •FFI ""‿"sqlite_close"
  sqlite_last_rowid_c ← "../lib.so" •FFI "u64"‿"sqlite_last_rowid"

  Init      ⇐ { Sqlite_init_c ⟨𝕩∾@+0⟩     }
  Close     ⇐ { 𝕊: Sqlite_close_c ⟨⟩      }
  LastRowId ⇐ { 𝕊: Sqlite_last_rowid_c ⟨⟩ }

  _Query ⇐ { Sqlite_exec_c ⟨𝕩∾@+0, 𝕗⟩   }
  Exec⇐{ d←⟨⟩ ⋄Sqlite_exec_c ⟨𝕩∾@+0, {d↩d∾⟨𝕩⟩}⟩ ⋄ d }

  Reset ⇐ { 𝕊:
    •SH "rm"‿"-r"‿"_data/db" 
  }
  Setup ⇐ { 𝕊:
    Init "_data/db"

    sql←•FChars "tables.sql"
    sql↩((∨`∧∨⟜«)' '⊸≠)⊸/sql 
    sql↩';'((⊢-˜+`×¬)∘=⊔⊢)sql
    Exec¨¯1↓sql
  }
}

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
    db.Exec "update bodies set start_line={}, end_line={}, start_col={}, end_col={} where id={}" Fmt start_line‿end_line‿start_col‿end_col‿id
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

val ⇐ {
  Rec⇐{ name‿⟨i,·⟩ 𝕊 v:
    ⟨id,file,call⟩←bodies.Peek @ 
    r← id‿name Ref file‿i

    Cache←{𝕊: n←≠data ⋄ data↩data∾⟨v⟩ ⋄ (𝕩⊸valm.Set)⊸⊢n }
    n← (valm.Has)◶Cache‿valm.Get •Hash v

    db.Exec "insert into vals(ref, data_index, call, type) values ({}, {}, {}, {})" Fmt r‿n‿call‿(•Type v)
  }
}

Restore⇐{
  d←db.Exec "
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

  # sort 𝕩 and 𝕨 to be 0 and 1 indices
  •Show d
  n←⊏⍉>d
  x←2×¬∨´¨"𝕩"⊸⍷¨n
  m←⍋x∨´¨"𝕨"⊸⍷¨n
  {n‿i: ⟨n,i⊑data⟩}¨m⊏d
}

