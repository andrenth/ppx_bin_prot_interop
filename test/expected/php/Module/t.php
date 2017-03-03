<?php

namespace Module;

function bin_read_t($buf, $pos) {
    list($var_0, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
    return array($var_0, $pos);
}

function bin_write_t($buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_int($buf, $pos, $v);
    return $pos;
}

function bin_size_t($v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_int($v);
    return $size;
}

class bin_t extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Module\bin_read_t', '\Module\bin_write_t', '\Module\bin_size_t');
    }
}
