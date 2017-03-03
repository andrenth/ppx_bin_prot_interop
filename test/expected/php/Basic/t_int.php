<?php

namespace Basic;

function bin_read_t_int($buf, $pos) {
    list($v, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
    return array($v, $pos);
}

function bin_write_t_int($buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_int($buf, $pos, $v);
    return $pos;
}

function bin_size_t_int($v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_int($v);
    return $size;
}

class bin_t_int extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Basic\bin_read_t_int', '\Basic\bin_write_t_int', '\Basic\bin_size_t_int');
    }
}
