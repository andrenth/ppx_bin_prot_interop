<?php

namespace Sum;

function bin_read_t($buf, $pos) {
    list($tag, $pos) = bin_prot\read\bin_read_int_8bit($buf, $pos);
    switch ($tag) {
    case 0:
        return array("A", null);
    case 1:
        list($var_100, $pos) = bin_prot\read\bin_read_int($buf, $pos);
        list($var_101, $pos) = bin_prot\read\bin_read_float($buf, $pos);
        $var_0 = array("x" => $var_100, "y" => $var_101);
        return array("B", $var_0);
    case 2:
        list($var_100, $pos) = bin_prot\read\bin_read_string($buf, $pos);
        list($var_101, $pos) = bin_prot\read\bin_read_char($buf, $pos);
        $var_0 = array($var_100, $var_101);
        return array("C", $var_0);
    case 3:
        return array("D", null);
    default:
        throw new bin_prot\exceptions\SumTag();
    }
    return array($tag, $pos);
}

function bin_write_t($buf, $pos, $v) {
    switch ($v[0]) {
    case "A":
        $pos = bin_prot\write\bin_write_int_8bit($buf, $pos, 0);
        return $pos;
    case "B":
        $pos = bin_prot\write\bin_write_int_8bit($buf, $pos, 1);
        $value = $v[1];
        $var_100 = $value["x"];
        $var_101 = $value["y"];
        $pos = bin_prot\write\bin_write_int($buf, $pos, $var_100);
        $pos = bin_prot\write\bin_write_float($buf, $pos, $var_101);
        return $pos;
    case "C":
        $pos = bin_prot\write\bin_write_int_8bit($buf, $pos, 2);
        $value = $v[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $pos = bin_prot\write\bin_write_string($buf, $pos, $var_100);
        $pos = bin_prot\write\bin_write_char($buf, $pos, $var_101);
        return $pos;
    case "D":
        $pos = bin_prot\write\bin_write_int_8bit($buf, $pos, 3);
        return $pos;
    default:
        throw new bin_prot\exceptions\SumTag();
    }
    return $pos;
}

function bin_size_t($v) {
    $size = 0;
    switch ($v[0]) {
    case "A":
        $size = $size + 1;
        return $size;
    case "B":
        $size = $size + 1;
        $value = $v[1];
        $var_100 = $value["x"];
        $var_101 = $value["y"];
        $size = $size + bin_prot\size\bin_size_int($var_100);
        $size = $size + bin_prot\size\bin_size_float($var_101);
        return $size;
    case "C":
        $size = $size + 1;
        $value = $v[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $size = $size + bin_prot\size\bin_size_string($var_100);
        $size = $size + bin_prot\size\bin_size_char($var_101);
        return $size;
    case "D":
        $size = $size + 1;
        return $size;
    default:
        throw new bin_prot\exceptions\SumTag();
    }
    return $size;
}

class bin_t extends bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct(bin_read_t, bin_write_t, bin_size_t);
    }
}
