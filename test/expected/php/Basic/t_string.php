<?php

namespace Basic;

function bin_read_t_string($buf, $pos) {
    list($var_0, $pos) = bin_prot\read\bin_read_string($buf, $pos);
    return array($var_0, $pos);
}

function bin_write_t_string($buf, $pos, $v) {
    $pos = bin_prot\write\bin_write_string($buf, $pos, $v);
    return $pos;
}

function bin_size_t_string($v) {
    $size = 0;
    $size = $size + bin_prot\size\bin_size_string($v);
    return $size;
}

class bin_t_string extends bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct(bin_read_t_string, bin_write_t_string, bin_size_t_string);
    }
}
