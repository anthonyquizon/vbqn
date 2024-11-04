-- 
PRAGMA foreign_keys = ON;
create table if not exists bodies(id int primary key, i int, start int, filename string);

create table if not exists vars  (body int, call int, name string, value string, foreign key(body) references bodies(id));
create table if not exists output(body int, call int, name string, value string, foreign key(body) references bodies(id));

create table if not exists history(i integer primary key autoincrement, body int, foreign key(body) references bodies(id));

-- create table if not exists vars_str(call int, name string, value string, foriegn key(call) REFERENCES bodies(id));
-- create table if not exists vars_num(call int, name string, value int,    foriegn key(call) REFERENCES bodies(id));

-- arrays? store bounds (min max) values?

