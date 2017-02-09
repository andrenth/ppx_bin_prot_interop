<?php

use bin_prot\read;
use bin_prot\write;
use bin_prot\size;

namespace List;

function bin_read_int_list($buf, $pos) {
    list($var_0, $pos) = bin_read_list("bin_read_int", $buf, $pos);
    return array($var_0, $pos);
}

function bin_write_int_list($buf, $pos, $v) {
    $pos = bin_write_list("bin_write_int", $buf, $pos, $v);
    return $pos;
}

function bin_size_int_list($v) {
    $size = 0;
    $size = $size + bin_size_list("bin_size_int", $v);
    return $size;
}

