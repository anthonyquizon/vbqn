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

.print 'ref vals'
select name, type, line, col from vals inner join refs on refs.id = vals.ref;

.print 'history'
select * from history;
"

find . -name '*.bqn' -o -name 'fern' -o -name '*.sql' -o -name '*.c' -o -name '*.test' | entr -r sh -c "
time (./fern test/_tmp/e2.bqn -i test/input.bqn && sqlite3 _data/db <<< \"$sql\")
"
