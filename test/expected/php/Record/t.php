<?php

namespace Record;

function bin_read_t($buf, $pos) {
    list($var_100, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
    list($var_101, $pos) = \bin_prot\read\bin_read_string($buf, $pos);
    list($var_202, $pos) = \bin_prot\read\bin_read_char($buf, $pos);
    list($var_203, $pos) = \bin_prot\read\bin_read_bool($buf, $pos);
    $var_102 = array($var_202, $var_203);
    list($vint, $pos) = \bin_prot\read\bin_read_variant_int($buf, $pos);
    $var_103 = "__dummy__";
    switch ($vint) {
    case 65:
        $var_103 = array("A", null);
        break;
    case 66:
        list($var_304, $pos) = \bin_prot\read\bin_read_float($buf, $pos);
        $var_103 = array("B", $var_304);
        break;
    case 67:
        $var_103 = array("C", null);
        break;
    default:
        throw new \bin_prot\NoVariantMatch();
    }
    list($var_104, $pos) = bin_read_option('\bin_prot\read\bin_read_int', $buf, $pos);
    $var_0 = array("a" => $var_100, "b" => $var_101, "c" => $var_102, "d" => $var_103, "e" => $var_104);
    return array($var_0, $pos);
}

function bin_write_t($buf, $pos, $v) {
    $var_100 = $v["a"];
    $var_101 = $v["b"];
    $var_102 = $v["c"];
    $var_103 = $v["d"];
    $var_104 = $v["e"];
    $var_202 = $var_102[0];
    $var_203 = $var_102[1];
    $pos = \bin_prot\write\bin_write_int($buf, $pos, $var_100);
    $pos = \bin_prot\write\bin_write_string($buf, $pos, $var_101);
    $pos = \bin_prot\write\bin_write_char($buf, $pos, $var_202);
    $pos = \bin_prot\write\bin_write_bool($buf, $pos, $var_203);
    switch ($var_103[0]) {
    case "A":
        $var_303 = $var_103[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 65);
        break;
    case "B":
        $var_304 = $var_103[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 66);
        $pos = \bin_prot\write\bin_write_float($buf, $pos, $var_304);
        break;
    case "C":
        $var_305 = $var_103[1];
        $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 67);
        break;
    default:
        throw new \bin_prot\NoVariantMatch();
    }
    $pos = bin_write_option('\bin_prot\write\bin_write_int', $buf, $pos, $var_104);
    return $pos;
}

function bin_size_t($v) {
    $size = 0;
    $var_100 = $v["a"];
    $var_101 = $v["b"];
    $var_102 = $v["c"];
    $var_103 = $v["d"];
    $var_104 = $v["e"];
    $var_202 = $var_102[0];
    $var_203 = $var_102[1];
    $size = $size + \bin_prot\size\bin_size_int($var_100);
    $size = $size + \bin_prot\size\bin_size_string($var_101);
    $size = $size + \bin_prot\size\bin_size_char($var_202);
    $size = $size + \bin_prot\size\bin_size_bool($var_203);
    switch ($var_103[0]) {
    case "A":
        $var_303 = $var_103[1];
        $size = $size + 4;
        break;
    case "B":
        $var_304 = $var_103[1];
        $size = $size + 4;
        $size = $size + \bin_prot\size\bin_size_float($var_304);
        break;
    case "C":
        $var_305 = $var_103[1];
        $size = $size + 4;
        break;
    default:
        throw new \bin_prot\NoVariantMatch();
    }
    $size = $size + bin_size_option('\bin_prot\size\bin_size_int', $var_104);
    return $size;
}

class bin_t extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Record\bin_read_t', '\Record\bin_write_t', '\Record\bin_size_t');
    }
}
