PRAGMA foreign_keys = ON;
create table if not exists bodies(id int primary key, line int, col int, file string);

create table if not exists refs(id integer primary key autoincrement, body int, name string, line int, col int, foreign key(body) references bodies(id));
create table if not exists vals(id integer primary key autoincrement, ref int, data_index int, type int, foreign key(ref) references refs(id));
-- TODO calls

create table if not exists history(i integer primary key autoincrement, body int, depth int, foreign key(body) references bodies(id));


