<?php

namespace Basic;

function bin_read_t_bool($buf, $pos) {
    list($var_0, $pos) = \bin_prot\read\bin_read_bool($buf, $pos);
    return array($var_0, $pos);
}

function bin_write_t_bool($buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_bool($buf, $pos, $v);
    return $pos;
}

function bin_size_t_bool($v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_bool($v);
    return $size;
}

class bin_t_bool extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Basic\bin_read_t_bool', '\Basic\bin_write_t_bool', '\Basic\bin_size_t_bool');
    }
}
