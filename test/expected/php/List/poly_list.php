<?php

use bin_prot\read;
use bin_prot\write;
use bin_prot\size;

namespace List;

function bin_read_poly_list($_of__a, $buf, $pos) {
    list($var_0, $pos) = bin_read_list($_of__a, $buf, $pos);
    return array($var_0, $pos);
}

function bin_write_poly_list($_of__a, $buf, $pos, $v) {
    $pos = bin_write_list($_of__a, $buf, $pos, $v);
    return $pos;
}

function bin_size_poly_list($_of__a, $v) {
    $size = 0;
    $size = $size + bin_size_list($_of__a, $v);
    return $size;
}

