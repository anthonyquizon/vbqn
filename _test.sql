.mode column
.headers on


select * from bodies;
select * from refs;

select DISTINCT * from refs 
    inner join calls on vals.call=calls.id 
    inner join vals on vals.ref = refs.id 
    inner join bodies 
    where refs.line <= bodies.end_line 
        and refs.line = (SELECT MAX(line) from refs)
        and refs.line >= bodies.start_line  
        and calls.id=4;

        -- SELECT i1.* 
-- FROM items i1
-- LEFT JOIN items i2 
    -- ON i1.name = i2.name 
    -- AND i1.value < i2.value
-- WHERE i2.id IS NULL;


