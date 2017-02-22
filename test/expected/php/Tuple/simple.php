<?php

namespace Tuple;

function bin_read_simple($buf, $pos) {
    list($var_100, $pos) = bin_prot\read\bin_read_int($buf, $pos);
    list($var_101, $pos) = bin_prot\read\bin_read_float($buf, $pos);
    $var_0 = array($var_100, $var_101);
    return array($var_0, $pos);
}

function bin_write_simple($buf, $pos, $v) {
    $var_100 = $v[0];
    $var_101 = $v[1];
    $pos = bin_prot\write\bin_write_int($buf, $pos, $var_100);
    $pos = bin_prot\write\bin_write_float($buf, $pos, $var_101);
    return $pos;
}

function bin_size_simple($v) {
    $size = 0;
    $var_100 = $v[0];
    $var_101 = $v[1];
    $size = $size + bin_prot\size\bin_size_int($var_100);
    $size = $size + bin_prot\size\bin_size_float($var_101);
    return $size;
}

