
cflags=-L_extern/cbqn/ -L_extern/replxx/build/ -I_extern/cbqn/include -I_extern/replxx/include/ -I_extern/sqlite/ -lreplxx -lstdc++ -lffi -lcbqn -lm 
all: lib.so _extern/bqn _extern/cbqn

_extern/bqn:
	mkdir -p _extern
	git clone https://github.com/mlochbaum/BQN.git --depth=1 _extern/bqn 

_extern/cbqn:
	mkdir -p _extern
	git clone https://github.com/dzaima/CBQN.git --depth=1 _extern/cbqn
	cd _extern/cbqn && make static-lib

# TODO sqlite3 download rule

_extern/sqlite/sqlite3.o: _extern/sqlite/sqlite3.c
	$(CC) -c ./_extern/sqlite/sqlite3.c -o ./_extern/sqlite/sqlite3.o

debug: _scratch/debug.c 
	$(CC) ./_extern/sqlite/sqlite3.o _scratch/debug.c $(cflags) -O0 -g -o debug

lib.so: src/lib.c _extern/sqlite/sqlite3.o
	$(CC) ./_extern/sqlite/sqlite3.o src/lib.c -g -shared $(cflags)  -o lib.so  
