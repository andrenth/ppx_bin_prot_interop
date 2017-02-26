<?php

namespace Complex;

function bin_read_u($buf, $pos) {
    list($var_100, $pos) = bin_prot\read\bin_read_string($buf, $pos);
    list($var_101, $pos) = bin_read_v($buf, $pos);
    $var_0 = array("x" => $var_100, "y" => $var_101);
    return array($var_0, $pos);
}

function bin_write_u($buf, $pos, $v) {
    $var_100 = $v["x"];
    $var_101 = $v["y"];
    $pos = bin_prot\write\bin_write_string($buf, $pos, $var_100);
    $pos = bin_write_v($buf, $pos, $var_101);
    return $pos;
}

function bin_size_u($v) {
    $size = 0;
    $var_100 = $v["x"];
    $var_101 = $v["y"];
    $size = $size + bin_prot\size\bin_size_string($var_100);
    $size = $size + bin_size_v($var_101);
    return $size;
}

class bin_u extends bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct(bin_read_u, bin_write_u, bin_size_u);
    }
}
