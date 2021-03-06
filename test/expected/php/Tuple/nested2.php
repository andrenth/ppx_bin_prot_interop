<?php

namespace Tuple;

function bin_read_nested2($buf, $pos) {
    list($var_100, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
    list($var_201, $pos) = \bin_prot\read\bin_read_string($buf, $pos);
    list($var_302, $pos) = \bin_prot\read\bin_read_bool($buf, $pos);
    list($var_303, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
    $var_202 = array($var_302, $var_303);
    list($var_203, $pos) = \bin_prot\read\bin_read_char($buf, $pos);
    $var_101 = array($var_201, $var_202, $var_203);
    list($var_102, $pos) = \bin_prot\read\bin_read_float($buf, $pos);
    $var_0 = array($var_100, $var_101, $var_102);
    return array($var_0, $pos);
}

function bin_write_nested2($buf, $pos, $v) {
    $var_100 = $v[0];
    $var_101 = $v[1];
    $var_102 = $v[2];
    $var_201 = $var_101[0];
    $var_202 = $var_101[1];
    $var_203 = $var_101[2];
    $var_302 = $var_202[0];
    $var_303 = $var_202[1];
    $pos = \bin_prot\write\bin_write_int($buf, $pos, $var_100);
    $pos = \bin_prot\write\bin_write_string($buf, $pos, $var_201);
    $pos = \bin_prot\write\bin_write_bool($buf, $pos, $var_302);
    $pos = \bin_prot\write\bin_write_int($buf, $pos, $var_303);
    $pos = \bin_prot\write\bin_write_char($buf, $pos, $var_203);
    $pos = \bin_prot\write\bin_write_float($buf, $pos, $var_102);
    return $pos;
}

function bin_size_nested2($v) {
    $size = 0;
    $var_100 = $v[0];
    $var_101 = $v[1];
    $var_102 = $v[2];
    $var_201 = $var_101[0];
    $var_202 = $var_101[1];
    $var_203 = $var_101[2];
    $var_302 = $var_202[0];
    $var_303 = $var_202[1];
    $size = $size + \bin_prot\size\bin_size_int($var_100);
    $size = $size + \bin_prot\size\bin_size_string($var_201);
    $size = $size + \bin_prot\size\bin_size_bool($var_302);
    $size = $size + \bin_prot\size\bin_size_int($var_303);
    $size = $size + \bin_prot\size\bin_size_char($var_203);
    $size = $size + \bin_prot\size\bin_size_float($var_102);
    return $size;
}

class bin_nested2 extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Tuple\bin_read_nested2', '\Tuple\bin_write_nested2', '\Tuple\bin_size_nested2');
    }
}
