<?php

namespace Variant;

function bin_read_t($buf, $pos) {
    list($vint, $pos) = \bin_prot\read\bin_read_variant_int($buf, $pos);
    $v = "__dummy__";
    switch ($vint) {
    case 65:
        $v = array("A", null);
        break;
    case 66:
        list($var_201, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
        $v = array("B", $var_201);
        break;
    case 67:
        list($var_302, $pos) = \bin_prot\read\bin_read_string($buf, $pos);
        list($var_303, $pos) = \bin_prot\read\bin_read_char($buf, $pos);
        $var_202 = array($var_302, $var_303);
        $v = array("C", $var_202);
        break;
    case 68:
        $v = array("D", null);
        break;
    default:
        throw new \bin_prot\NoVariantMatch();
    }
    return array($v, $pos);
}

function bin_write_t($buf, $pos, $v) {
    switch ($v[0]) {
    case "A":
        $var_200 = $v[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 65);
        break;
    case "B":
        $var_201 = $v[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 66);
        $pos = \bin_prot\write\bin_write_int($buf, $pos, $var_201);
        break;
    case "C":
        $var_202 = $v[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 67);
        $var_302 = $var_202[0];
        $var_303 = $var_202[1];
        $pos = \bin_prot\write\bin_write_string($buf, $pos, $var_302);
        $pos = \bin_prot\write\bin_write_char($buf, $pos, $var_303);
        break;
    case "D":
        $var_203 = $v[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 68);
        break;
    default:
        throw new \bin_prot\NoVariantMatch();
    }
    return $pos;
}

function bin_size_t($v) {
    $size = 0;
    switch ($v[0]) {
    case "A":
        $var_200 = $v[1];
        $size = $size + 4;
        break;
    case "B":
        $var_201 = $v[1];
        $size = $size + 4;
        $size = $size + \bin_prot\size\bin_size_int($var_201);
        break;
    case "C":
        $var_202 = $v[1];
        $size = $size + 4;
        $var_302 = $var_202[0];
        $var_303 = $var_202[1];
        $size = $size + \bin_prot\size\bin_size_string($var_302);
        $size = $size + \bin_prot\size\bin_size_char($var_303);
        break;
    case "D":
        $var_203 = $v[1];
        $size = $size + 4;
        break;
    default:
        throw new \bin_prot\NoVariantMatch();
    }
    return $size;
}

class bin_t extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Variant\bin_read_t', '\Variant\bin_write_t', '\Variant\bin_size_t');
    }
}
