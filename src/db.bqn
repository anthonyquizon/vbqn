
# i32:c8 → i32: the c data type that is converted to and c8: the bqn data type that is converted from
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
