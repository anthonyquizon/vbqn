PRAGMA foreign_keys = ON;
create table if not exists bodies(id int primary key, start_line int, end_line int, start_col int, end_col int, file string);

create table if not exists refs(id integer primary key autoincrement, body int, name string, line int, col int, foreign key(body) references bodies(id));
create table if not exists vals(id integer primary key autoincrement, ref int, call int, data_index int, type int, foreign key(ref) references refs(id), foreign key(call) references calls(id)); -- TODO call id
create table if not exists calls(id integer primary key autoincrement, body int, depth int, foreign key(body) references bodies(id));


