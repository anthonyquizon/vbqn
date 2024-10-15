
all: lib.so _extern/bqn _extern/cbqn

_extern/bqn:
	mkdir -p _extern
	git clone https://github.com/mlochbaum/BQN.git --depth=1 _extern/bqn 

_extern/cbqn:
	mkdir -p _extern
	git clone https://github.com/dzaima/CBQN.git --depth=1 _extern/cbqn
	cd _extern/cbqn && make static-lib

#debug: src/lib.c 
	#$(CC) src/lib.c -L_extern/cbqn/ -lffi -lreplxx -lcbqn -I_extern/cbqn/include -lstdc++ -O0 -g -o debug

debug: _scratch/debug.c 
	$(CC) _scratch/debug.c -L_extern/replxx/build/ -I_extern/replxx/include/ -lreplxx -lstdc++ -O0 -g -o debug

lib.so: src/lib.c
	$(CC) src/lib.c -g -shared -L_extern/cbqn/ -lffi -lreplxx -lcbqn -I_extern/cbqn/include -lstdc++ -O0 -lm -o lib.so  
