#!/bin/sh

run_test() {
  name=$1
  ./_build/ppx test/$name.ml > /dev/null
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

rm -rf interop

for t in test/*ml; do
  name=`basename $t .ml`
  echo -n "[-] Generating code for test '$name': "
  ok_or_error run_test $name
done

for lang in `ls interop`; do
  echo "[-] Checking $lang output"
  for test in `ls test/expected/$lang`; do
    echo -n "    * $test: "
    ok_or_error diff -ru test/expected/$lang/$test interop/$lang/$test
  done
done
