cflags=-lsqlite3 -lcbqn -lm 

all: lib.so 

lib.so: src/lib.c 
	$(CC) src/lib.c -g -shared $(cflags)  -o lib.so  
