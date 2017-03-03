<?php

namespace Basic;

function bin_read_t_char($buf, $pos) {
    list($v, $pos) = \bin_prot\read\bin_read_char($buf, $pos);
    return array($v, $pos);
}

function bin_write_t_char($buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_char($buf, $pos, $v);
    return $pos;
}

function bin_size_t_char($v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_char($v);
    return $size;
}

class bin_t_char extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Basic\bin_read_t_char', '\Basic\bin_write_t_char', '\Basic\bin_size_t_char');
    }
}
