#!/bin/bash

run_test() {
  name=$1
  ./test_ppx $name.ml > /dev/null
}

ok_or_error() {
  out=`$@ 2>&1`
  if [ $? -eq 0 ]; then
    echo "OK"
  else
    echo "ERROR"
    echo "-------------------------------------------------------------"
    /bin/echo "$out"
    echo "============================================================="
  fi
}

build_root=$1
project_root=$build_root/../..

for t in $build_root/test/*.ml; do
  name=`basename $t .ml`
  echo -n "[-] Generating code for test '$name': "
  ok_or_error run_test $name
done

for lang in `ls interop`; do
  expected=$project_root/test/expected
  echo "[-] Checking $lang output"
  for test in `ls $expected/$lang`; do
    t=`basename $test`
    echo -n "    * $test: "
    ok_or_error diff -ru $expected/$lang/$test interop/$lang/$test
  done
done
