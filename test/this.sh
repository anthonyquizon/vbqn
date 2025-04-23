#! /usr/bin/env bash
cd "$(dirname "$0")"
export TIMEFORMAT='%3R'
../vbqn -v v.bqn a.bqn
