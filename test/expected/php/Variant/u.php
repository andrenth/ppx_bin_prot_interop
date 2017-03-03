<?php

namespace Variant;

function bin_read_u($buf, $pos) {
    list($vint, $pos) = \bin_prot\read\bin_read_variant_int($buf, $pos);
    $v = "__dummy__";
    switch ($vint) {
    case 88:
        list($var_200, $pos) = \bin_prot\read\bin_read_float($buf, $pos);
        $v = array("X", $var_200);
        break;
    default:
        throw new \bin_prot\exceptions\NoVariantMatch();
    }
    return array($v, $pos);
}

function bin_write_u($buf, $pos, $v) {
    switch ($v[0]) {
    case "X":
        $var_200 = $v[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 88);
        $pos = \bin_prot\write\bin_write_float($buf, $pos, $var_200);
        break;
    default:
        throw new \bin_prot\exceptions\NoVariantMatch();
    }
    return $pos;
}

function bin_size_u($v) {
    $size = 0;
    switch ($v[0]) {
    case "X":
        $var_200 = $v[1];
        $size = $size + 4;
        $size = $size + \bin_prot\size\bin_size_float($var_200);
        break;
    default:
        throw new \bin_prot\exceptions\NoVariantMatch();
    }
    return $size;
}

class bin_u extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Variant\bin_read_u', '\Variant\bin_write_u', '\Variant\bin_size_u');
    }
}
