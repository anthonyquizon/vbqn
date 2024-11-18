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
select name, type, data_index, line, col, call from vals inner join refs on refs.id = vals.ref;

.print 'calls'
select * from calls;
"

find . -name '*.bqn' -o -name 'fern' -o -name '*.sql' -o -name '*.c' -o -name '*.test' | entr -r sh -c "
time (./fern test/_tmp/e2.bqn -i test/input.bqn && sqlite3 _data/db < _test.sql)
"
