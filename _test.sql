.mode column
.headers on


-- select * from bodies;
-- select * from refs;
select * from vals;
select * from calls;

select name, max(line) from refs 
    inner join calls on vals.call=calls.id 
    inner join vals on vals.ref = refs.id 
    inner join bodies 
    where   
        refs.line >= bodies.start_line  and 
        refs.line <= 4    and 
        calls.id=4
    group by 
        refs.name
    ;

