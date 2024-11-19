db←•Import "src/db.bqn"
repl←•Import "src/r.bqn"

db.Setup@
 {
    •Show 𝕩
    0
 } db._Query "select * from refs"
