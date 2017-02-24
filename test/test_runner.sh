#!/bin/sh

run_test() {
  name=$1
  ./_build/ppx test/$name.ml > /dev/null
}

for i in test/*ml; do
  test=`basename $i .ml`
  run_test $test
done

diff -ruN test/expected interop
