cflags=-lsqlite3 -lcbqn -lm 

all: _extern/bqn lib.so 

_extern/bqn:
	mkdir -p _extern
	git clone https://github.com/mlochbaum/BQN.git --depth=1 _extern/bqn 

lib.so: src/lib.c 
	$(CC) src/lib.c -g -shared $(cflags)  -o lib.so  
