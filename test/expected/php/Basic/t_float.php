<?php

namespace Basic;

function bin_read_t_float($buf, $pos) {
    list($v, $pos) = \bin_prot\read\bin_read_float($buf, $pos);
    return array($v, $pos);
}

function bin_write_t_float($buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_float($buf, $pos, $v);
    return $pos;
}

function bin_size_t_float($v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_float($v);
    return $size;
}

class bin_t_float extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Basic\bin_read_t_float', '\Basic\bin_write_t_float', '\Basic\bin_size_t_float');
    }
}
