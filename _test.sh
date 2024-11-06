export TIMEFORMAT='%3R'

find . -name '*.bqn' -o -name 'dbqn' -o -name '*.sql' -o -name '*.c' -o -name '*.test' | entr -r sh -c "
time ./dbqn test/foo.bqn && \
    echo 'bodies'
    litecli _data/db <<< 'select * from bodies;exit'
    echo 'vars'
    litecli _data/db <<< 'select * from vars;exit'
    echo 'history'
    litecli _data/db <<< 'select * from history;exit'
"
