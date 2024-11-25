
cflags=-L_extern/cbqn/ -L_extern/replxx/build/ -I_extern/cbqn/include -I_extern/replxx/include/ -I_extern/sqlite/ -lreplxx -lstdc++ -lffi -lcbqn -lm 
all: lib.so 

debug: _scratch/debug.c 
	$(CC) ./_extern/sqlite/sqlite3.o _scratch/debug.c $(cflags) -O0 -g -o debug

lib.so: src/lib.c 
	$(CC) ./_extern/sqlite/sqlite3.o src/lib.c -g -shared $(cflags)  -o lib.so  

test/lib.so: test/lib.c 
	$(CC) test/lib.c -g -shared $(cflags)  -o test/lib.so  
