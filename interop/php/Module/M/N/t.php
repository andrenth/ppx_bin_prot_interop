<?php

namespace Module\M\N;

function bin_read_t($buf, $pos) {
    list($v, $pos) = \bin_prot\read\bin_read_bool($buf, $pos);
    return array($v, $pos);
}

function bin_write_t($buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_bool($buf, $pos, $v);
    return $pos;
}

function bin_size_t($v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_bool($v);
    return $size;
}

class bin_t extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Module\M\N\bin_read_t', '\Module\M\N\bin_write_t', '\Module\M\N\bin_size_t');
    }
}
