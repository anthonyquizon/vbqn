
all: lib.so _extern/bqn _extern/cbqn

_extern/bqn:
	mkdir -p _extern
	git clone https://github.com/mlochbaum/BQN.git --depth=1 _extern/bqn 

_extern/cbqn:
	mkdir -p _extern
	git clone https://github.com/dzaima/CBQN.git --depth=1 _extern/cbqn
	cd _extern/cbqn && make static-lib

lib.so: src/lib.c _extern/replxx
	$(CC) src/lib.c -shared -L_extern/cbqn/ -lffi -lreplxx -lcbqn -I_extern/cbqn/include -lstdc++ -lm -o lib.so  
