-- 
PRAGMA foreign_keys = ON;
create table if not exists bodies(id int primary key, start int, file string);

create table if not exists refs(id integer primary key autoincrement, body int, name string, line int, col int, foreign key(body) references bodies(id));
create table if not exists vals(id integer primary key autoincrement, ref int, i int, type int, foreign key(ref) references refs(id));
-- TODO calls

-- create table if not exists vars  (body int, call int, name string, value string, reified boolean, foreign key(body) references bodies(id));
-- create table if not exists output(body int, call int, name string, value string, foreign key(body) references bodies(id));

create table if not exists history(i integer primary key autoincrement, body int, foreign key(body) references bodies(id));


