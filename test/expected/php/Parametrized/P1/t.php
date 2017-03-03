<?php

namespace Parametrized\P1;

function bin_read_t($_of__a, $buf, $pos) {
    list($var_0, $pos) = \bin_prot\read\bin_read_list($_of__a, $buf, $pos);
    return array($var_0, $pos);
}

function bin_write_t($_of__a, $buf, $pos, $v) {
    $pos = \bin_prot\write\bin_write_list($_of__a, $buf, $pos, $v);
    return $pos;
}

function bin_size_t($_of__a, $v) {
    $size = 0;
    $size = $size + \bin_prot\size\bin_size_list($_of__a, $v);
    return $size;
}

class bin_t extends \bin_prot\type_class\type_class {
    public function __construct($bin0)
    {
        $this->_read = function($buf, $pos) use ($bin0) {
            bin_read_t($bin0->read(), $buf, $pos);
        };
        $this->_write = function($buf, $pos, $v) use ($bin0) {
            bin_write_t($bin0->write(), $buf, $pos, $v);
        };
        $this->_size = function($v) use ($bin0) {
            bin_size_t($bin0->size(), $v);
        };
    }
}
