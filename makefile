
all: lib.so _extern/bqn 

_extern/bqn:
	mkdir -p _extern
	git clone https://github.com/mlochbaum/BQN.git --depth=1 _extern/bqn 

_extern/cbqn:
	mkdir -p _extern
	git clone https://github.com/dzaima/CBQN.git --depth=1 _extern/cbqn

_extern/replxx:
	mkdir -p _extern
	git clone https://github.com/AmokHuginnsson/replxx.git --depth=1 _extern/replxx

lib.so: src/lib.c _extern/replxx
	$(CC) src/lib.c -shared -L_extern/replxx/build/ -lreplxx -I_extern/replxx/include -lstdc++ -lm -o lib.so 
