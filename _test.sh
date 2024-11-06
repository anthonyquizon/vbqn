export TIMEFORMAT='%3R'

find . -name '*.bqn' -o -name 'dbqn' -o -name '*.sql' -o -name '*.c' -o -name '*.test' | entr -r sh -c "
time ./dbqn test/foo.bqn -i test/input.bqn && \
    echo 'bodies'
    litecli _data/db <<< 'select * from bodies;exit'
    echo 'refs'
    litecli _data/db <<< 'select * from refs;exit'
    echo 'vals'
    litecli _data/db <<< 'select * from vals;exit'
    echo 'history'
    litecli _data/db <<< 'select * from history;exit'
"
