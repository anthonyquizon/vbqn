⟨⟨Fmt⟩⇐strings, ns⟩ ←•Import "util.bqn"
db←•Import "db.bqn"
init_c  ← "../lib.so" •FFI ""‿"init"
input_c ← "../lib.so" •FFI "a"‿"input"

p ← ⟨⟩ •HashMap ⟨⟩ # inspection points

Init_c ⟨⟩

List←{ 
  𝕩 
}

Help ← {𝕩 }

Query←{ 
  𝕊: 𝕩
  #•Show "query"‿𝕩
}

History←{ 𝕊:
  𝕩
}

# Repl specific operations
opts←⍉[
  "?"‿Query

  "?h"‿Help
  "?help"‿Help

  "?l"‿List
  "?list"‿List
  #")r"‿R
  # TODO explain
]

system←⟨
  "show"‿•Show, 
  "query"‿Query, "q"‿Query,
  "history"‿History, "h"‿History
⟩

repl← •ReBqn {repl⇐"loose"⋄ system⇐system}

Eval ← { 𝕊 l:
  n←≠¨⊏opts ⋄ m←∾n{𝕩⍷𝕨↑l}¨⊏opts ⋄ {f←1⊑𝕩⋄F l}˘m/⍉opts # run opts eg. )l

  # get all variables after line in body
  # inject into repl
  # auto complete line fragements

  {𝕊:•Show Repl⎊•CurrentError l}⍟((0<≠l)∧¬∨´m) @ # run repl
}

l←4

Set⇐{ 𝕊:
  
  repl↩•ReBqn {repl⇐"loose"⋄ system⇐system}
  
  db.Exec •SHow "
      select name, max(line) from refs 
        inner join calls on vals.call=calls.id 
        inner join vals on vals.ref = refs.id 
        inner join bodies 
        where   
            refs.line >= bodies.start_line  and 
            refs.line <= {}                 and 
            calls.id={}
        group by 
            refs.name
  " Fmt 4‿2
  #select DISTINCT * from refs 
      #inner join calls on vals.call=calls.id 
      #inner join vals on vals.ref = refs.id 
      #inner join bodies 
      #where refs.line <= bodies.end_line 
          #and refs.line = (SELECT MAX(line) from refs)
          #and refs.line >= bodies.start_line  
          #and calls.id=4;


  #⟨"","",⟩ Repl ""

}

Run⇐{ 
  𝕊 ⟨⟩: 
    { 𝕊:
      l←Input_c ⟨⟩ 
      •Show l
      •Exit⍟(l=0) 0 # run cancel
      Eval l
    }•_while_ 1 1 
; 𝕊 𝕩: Eval¨𝕩
}

