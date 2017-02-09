<?php

use bin_prot\read;
use bin_prot\write;
use bin_prot\size;

namespace Basic;

function bin_read_t_int($buf, $pos) {
    list($var_0, $pos) = bin_read_int($buf, $pos);
    return array($var_0, $pos);
}

function bin_write_t_int($buf, $pos, $v) {
    $pos = bin_write_int($buf, $pos, $v);
    return $pos;
}

function bin_size_t_int($v) {
    $size = 0;
    $size = $size + bin_size_int($v);
    return $size;
}

