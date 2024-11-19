db←•Import "src/db.bqn"
repl←•Import "src/r.bqn"

#db.Setup@
 #{
    #•Show 𝕩
    #1
 #} db._Query "select * from refs"

 db.Setup @
 repl.Set 4‿2
