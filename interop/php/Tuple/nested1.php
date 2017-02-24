<?php

namespace Tuple;

function bin_read_nested1($buf, $pos) {
    list($var_100, $pos) = bin_prot\read\bin_read_int($buf, $pos);
    list($var_201, $pos) = bin_prot\read\bin_read_string($buf, $pos);
    list($var_202, $pos) = bin_prot\read\bin_read_char($buf, $pos);
    $var_101 = array($var_201, $var_202);
    list($var_102, $pos) = bin_prot\read\bin_read_float($buf, $pos);
    $var_0 = array($var_100, $var_101, $var_102);
    return array($var_0, $pos);
}

function bin_write_nested1($buf, $pos, $v) {
    $var_100 = $v[0];
    $var_101 = $v[1];
    $var_102 = $v[2];
    $var_201 = $var_101[0];
    $var_202 = $var_101[1];
    $pos = bin_prot\write\bin_write_int($buf, $pos, $var_100);
    $pos = bin_prot\write\bin_write_string($buf, $pos, $var_201);
    $pos = bin_prot\write\bin_write_char($buf, $pos, $var_202);
    $pos = bin_prot\write\bin_write_float($buf, $pos, $var_102);
    return $pos;
}

function bin_size_nested1($v) {
    $size = 0;
    $var_100 = $v[0];
    $var_101 = $v[1];
    $var_102 = $v[2];
    $var_201 = $var_101[0];
    $var_202 = $var_101[1];
    $size = $size + bin_prot\size\bin_size_int($var_100);
    $size = $size + bin_prot\size\bin_size_string($var_201);
    $size = $size + bin_prot\size\bin_size_char($var_202);
    $size = $size + bin_prot\size\bin_size_float($var_102);
    return $size;
}

class bin_nested1 extends bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct(bin_read_nested1, bin_write_nested1, bin_size_nested1);
    }
}
