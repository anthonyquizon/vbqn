#! /usr/bin/env bash
find . -name '*.bqn' | entr ./test/this.sh
