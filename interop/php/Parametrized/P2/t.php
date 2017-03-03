<?php

namespace Parametrized\P2;

function bin_read_t($_of__a, $_of__b, $buf, $pos) {
    list($var_100, $pos) = $_of__a($buf, $pos);
    list($var_101, $pos) = \bin_prot\read\bin_read_list($_of__b, $buf, $pos);
    $var_0 = array($var_100, $var_101);
    return array($var_0, $pos);
}

function bin_write_t($_of__a, $_of__b, $buf, $pos, $v) {
    $var_100 = $v[0];
    $var_101 = $v[1];
    $pos = $_of__a($buf, $pos, $var_100);
    $pos = \bin_prot\write\bin_write_list($_of__b, $buf, $pos, $var_101);
    return $pos;
}

function bin_size_t($_of__a, $_of__b, $v) {
    $size = 0;
    $var_100 = $v[0];
    $var_101 = $v[1];
    $pos = $_of__a($var_100);
    $size = $size + \bin_prot\size\bin_size_list($_of__b, $var_101);
    return $size;
}

class bin_t extends \bin_prot\type_class\type_class {
    public function __construct($bin0, $bin1)
    {
        $this->_read = function($buf, $pos) use ($bin0, $bin1) {
            bin_read_t($bin0->read(), $bin1->read(), $buf, $pos);
        };
        $this->_write = function($buf, $pos, $v) use ($bin0, $bin1) {
            bin_write_t($bin0->write(), $bin1->write(), $buf, $pos, $v);
        };
        $this->_size = function($v) use ($bin0, $bin1) {
            bin_size_t($bin0->size(), $bin1->size(), $v);
        };
    }
}
