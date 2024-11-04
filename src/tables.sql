-- 
create table if not exists bodies(id int primary key, filename string, call string, out string);

create table if not exists vars(call int, name string, value string, foreign key(call) references bodies(id));
-- create table if not exists vars_str(call int, name string, value string, foriegn key(call) REFERENCES bodies(id));
-- create table if not exists vars_num(call int, name string, value int,    foriegn key(call) REFERENCES bodies(id));

-- arrays? store bounds (min max) values?

