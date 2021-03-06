<?php

namespace List;

function bin_read_poly_list($_of__a, $buf, $pos) {
    list($v, $pos) = \bin_prot\read\bin_read_list($_of__a, $buf, $pos);
    return array($v, $pos);
}

function bin_write_poly_list($_of__a, $buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_list($_of__a, $buf, $pos, $v);
    return $pos;
}

function bin_size_poly_list($_of__a, $v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_list($_of__a, $v);
    return $size;
}

class bin_poly_list extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\List\bin_read_poly_list', '\List\bin_write_poly_list', '\List\bin_size_poly_list');
    }
}
