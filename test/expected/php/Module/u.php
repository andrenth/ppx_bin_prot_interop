<?php

namespace Module;

function bin_read_u($buf, $pos) {
    list($var_100, $pos) = bin_read_t($buf, $pos);
    list($var_101, $pos) = M\bin_read_t($buf, $pos);
    list($var_102, $pos) = M\N\bin_read_t($buf, $pos);
    $var_0 = array("x" => $var_100, "y" => $var_101, "z" => $var_102);
    return array($var_0, $pos);
}

function bin_write_u($buf, $pos, $v) {
    $var_100 = $v["x"];
    $var_101 = $v["y"];
    $var_102 = $v["z"];
    $pos = bin_write_t($buf, $pos, $var_100);
    $pos = M\bin_write_t($buf, $pos, $var_101);
    $pos = M\N\bin_write_t($buf, $pos, $var_102);
    return $pos;
}

function bin_size_u($v) {
    $size = 0;
    $var_100 = $v["x"];
    $var_101 = $v["y"];
    $var_102 = $v["z"];
    $size = $size + bin_size_t($var_100);
    $size = $size + M\bin_size_t($var_101);
    $size = $size + M\N\bin_size_t($var_102);
    return $size;
}

class bin_u extends bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct(bin_read_u, bin_write_u, bin_size_u);
    }
}
