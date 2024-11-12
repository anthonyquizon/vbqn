export TIMEFORMAT='%3R'

sql="
.mode column
.headers on
.print 'bodies'
select * from bodies;

.print 'refs'
select * from refs;

.print 'vals'
select * from vals;

.print 'history'
select * from history;
"

find . -name '*.bqn' -o -name 'fern' -o -name '*.sql' -o -name '*.c' -o -name '*.test' | entr -r sh -c "
time (./fern test/_tmp/foo.bqn -i test/input.bqn && sqlite3 _data/db <<< \"$sql\")
"
