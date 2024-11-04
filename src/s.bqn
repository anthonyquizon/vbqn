
cm      ⇐ ⟨⟩ •HashMap ⟨⟩ # count of each function call
vm      ⇐ ⟨⟩ •HashMap ⟨⟩ # variables and arguments
idm     ⇐ ⟨⟩ •HashMap ⟨⟩
outm    ⇐ ⟨⟩ •HashMap ⟨⟩
history ⇐ ⟨⟩

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
    s.Push ⟨•file.Parent "../"∾f, •file.Chars "../"∾f, f⟩
  }

  Peek ⇐ s.Peek
  Pop  ⇐ s.Pop
}

# Hash: start‿filename‿c
bodies ⇐ {
  s⇐ MakeStack ⟨⟩

  Push⇐{
    start‿args←𝕩
      ⟨·,·,file⟩ ←ctx.Peek @
      i ← start∾⟨file⟩
      j  ← cm.Has◶{𝕩 cm.Set 0 ⋄ 0}‿cm.Get i
      i cm.Set j+1
      id ← (idm.Count @)
      (i∾j) idm.Set id

      history ∾⟜(⟨id⟩)↩
      s.Push id
  }

  Pop⇐{ (⊑s.Pop 1) outm.Set 𝕩 }

  Rec⇐{
    id ←s.Peek @
    (id∾𝕨) vm.Set 𝕩
  }
}

# i32:c8 → i32: the c data type that is converted to and c8: the bqn data type that is converted from
sql⇐{
  sqlite_init_c  ← "../lib.so" •FFI "u64"‿"sqlite_init"‿"*u8:c8"
  sqlite_exec_c  ← "../lib.so" •FFI "u64"‿"sqlite_exec"‿"*u8:c8"
  sqlite_close_c ← "../lib.so" •FFI ""‿"sqlite_close"

  Init  ⇐ { Sqlite_init_c ⟨𝕩∾@+0⟩ }
  Exec  ⇐ { Sqlite_exec_c ⟨𝕩∾@+0⟩ }
  Close ⇐ { 𝕊: Sqlite_close_c ⟨⟩ }
  Populate ⇐ { 𝕊:
    "v"‿"out"‿"idm"{•Show 𝕨 ⋄ •Show >(𝕩.Keys @)‿(𝕩.Values @)}¨vm‿outm‿idm
    •Show history
    •Show "--"

    •SHow •FChars "tables.sql"
    sql.Init "db"
    #sql.Exec "create table if not exists foo (a string, b int, c double)"
    #sql.Exec "
      #insert into foo (a, b, c) values ('foo', 222, 1.2);
      #insert into foo (a, b, c) values ('foo', 999, 1.2);
      #insert into foo (a, b, c) values ('foo', 0, 1.2);
      #insert into foo (a, b, c) values ('foo', 123, 1.2);
      #insert into foo (a, b, c) values ('foo', 223, 1.2);

    #"

    files←⍷1⊸⊑¨idm.Keys @
    vars←1⊑¨vm.Keys @
    vals←vm.Values @

    •SHow "foo"⊸⍷¨files

    #•Show vals/˜vars='𝕩'∧file=''
    # order by history
    # (vars=a)∧(file="foo*")
  }
}


