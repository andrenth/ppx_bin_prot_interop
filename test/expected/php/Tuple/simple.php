<?php

use bin_prot\read;
use bin_prot\write;
use bin_prot\size;

namespace Tuple;

function bin_read_simple($buf, $pos) {
    list($var_100, $pos) = bin_read_int($buf, $pos);
    list($var_101, $pos) = bin_read_float($buf, $pos);
    $var_0 = array($var_100, $var_101);
    return array($var_0, $pos);
}

function bin_write_simple($buf, $pos, $v) {
    $var_100 = $value[0];
    $var_101 = $value[1];
    $pos = bin_write_int($buf, $pos, $var_100);
    $pos = bin_write_float($buf, $pos, $var_101);
    return $pos;
}

function bin_size_simple($v) {
    $size = 0;
    $var_100 = $value[0];
    $var_101 = $value[1];
    $size = $size + bin_size_int($var_100);
    $size = $size + bin_size_float($var_101);
    return $size;
}

