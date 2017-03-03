<?php

namespace Complex;

function bin_read_t($buf, $pos) {
    list($tag, $pos) = \bin_prot\read\bin_read_int_8bit($buf, $pos);
    switch ($tag) {
    case 0:
        list($var_0, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
        return array("A", $var_0);
    case 1:
        list($var_0, $pos) = bin_read_u($buf, $pos);
        return array("B", $var_0);
    case 2:
        list($var_100, $pos) = \bin_prot\read\bin_read_string($buf, $pos);
        list($var_101, $pos) = \bin_prot\read\bin_read_float($buf, $pos);
        list($var_102, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
        $var_0 = array($var_100, $var_101, $var_102);
        return array("C", $var_0);
    case 3:
        list($var_100, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
        list($var_201, $pos) = \bin_prot\read\bin_read_char($buf, $pos);
        list($var_202, $pos) = \bin_prot\read\bin_read_bool($buf, $pos);
        $var_101 = array($var_201, $var_202);
        list($var_102, $pos) = \bin_prot\read\bin_read_string($buf, $pos);
        $var_0 = array($var_100, $var_101, $var_102);
        return array("D", $var_0);
    case 4:
        return array("X", null);
    case 5:
        $var_0 = "__dummy__";
        list($vint, $pos) = \bin_prot\read\bin_read_variant_int($buf, $pos);
        switch ($vint) {
        case 77:
            list($var_200, $pos) = \bin_prot\read\bin_read_int($buf, $pos);
            $var_0 = array("M", $var_200);
            break;
        case 78:
            $var_0 = array("N", null);
            break;
        default:
            throw new \bin_prot\exceptions\NoVariantMatch();
        }
    case 6:
        list($var_100, $pos) = \bin_prot\read\bin_read_string($buf, $pos);
        list($var_101, $pos) = \bin_prot\read\bin_read_list('\bin_prot\read\bin_read_int', $buf, $pos);
        $var_0 = array("m" => $var_100, "n" => $var_101);
        return array("Z", $var_0);
    default:
        throw new \bin_prot\exceptions\SumTag();
    }
    return array($tag, $pos);
}

function bin_write_t($buf, $pos, $v) {
    switch ($v[0]) {
    case "A":
        $pos = \bin_prot\write\bin_write_int_8bit($buf, $pos, 0);
        $value = $v[1];
        $pos = \bin_prot\write\bin_write_int($buf, $pos, $v);
        return $pos;
    case "B":
        $pos = \bin_prot\write\bin_write_int_8bit($buf, $pos, 1);
        $value = $v[1];
        $pos = bin_write_u($buf, $pos, $v);
        return $pos;
    case "C":
        $pos = \bin_prot\write\bin_write_int_8bit($buf, $pos, 2);
        $value = $v[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $var_102 = $value[2];
        $pos = \bin_prot\write\bin_write_string($buf, $pos, $var_100);
        $pos = \bin_prot\write\bin_write_float($buf, $pos, $var_101);
        $pos = \bin_prot\write\bin_write_int($buf, $pos, $var_102);
        return $pos;
    case "D":
        $pos = \bin_prot\write\bin_write_int_8bit($buf, $pos, 3);
        $value = $v[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $var_102 = $value[2];
        $var_201 = $var_101[0];
        $var_202 = $var_101[1];
        $pos = \bin_prot\write\bin_write_int($buf, $pos, $var_100);
        $pos = \bin_prot\write\bin_write_char($buf, $pos, $var_201);
        $pos = \bin_prot\write\bin_write_bool($buf, $pos, $var_202);
        $pos = \bin_prot\write\bin_write_string($buf, $pos, $var_102);
        return $pos;
    case "X":
        $pos = \bin_prot\write\bin_write_int_8bit($buf, $pos, 4);
        return $pos;
    case "Y":
        $pos = \bin_prot\write\bin_write_int_8bit($buf, $pos, 5);
        $value = $v[1];
        switch ($v[0]) {
        case "M":
            $var_200 = $var_0[1];
            $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 77);
            $pos = \bin_prot\write\bin_write_int($buf, $pos, $var_200);
            break;
        case "N":
            $var_201 = $var_0[1];
            $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 78);
            break;
        default:
            throw new \bin_prot\exceptions\NoVariantMatch();
        }
    case "Z":
        $pos = \bin_prot\write\bin_write_int_8bit($buf, $pos, 6);
        $value = $v[1];
        $var_100 = $value["m"];
        $var_101 = $value["n"];
        $pos = \bin_prot\write\bin_write_string($buf, $pos, $var_100);
        $pos = \bin_prot\write\bin_write_list('\bin_prot\write\bin_write_int', $buf, $pos, $var_101);
        return $pos;
    default:
        throw new \bin_prot\exceptions\SumTag();
    }
    return $pos;
}

function bin_size_t($v) {
    $size = 0;
    switch ($v[0]) {
    case "A":
        $size = $size + 1;
        $value = $v[1];
        $size = $size + \bin_prot\size\bin_size_int($v);
        return $size;
    case "B":
        $size = $size + 1;
        $value = $v[1];
        $size = $size + bin_size_u($v);
        return $size;
    case "C":
        $size = $size + 1;
        $value = $v[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $var_102 = $value[2];
        $size = $size + \bin_prot\size\bin_size_string($var_100);
        $size = $size + \bin_prot\size\bin_size_float($var_101);
        $size = $size + \bin_prot\size\bin_size_int($var_102);
        return $size;
    case "D":
        $size = $size + 1;
        $value = $v[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $var_102 = $value[2];
        $var_201 = $var_101[0];
        $var_202 = $var_101[1];
        $size = $size + \bin_prot\size\bin_size_int($var_100);
        $size = $size + \bin_prot\size\bin_size_char($var_201);
        $size = $size + \bin_prot\size\bin_size_bool($var_202);
        $size = $size + \bin_prot\size\bin_size_string($var_102);
        return $size;
    case "X":
        $size = $size + 1;
        return $size;
    case "Y":
        $size = $size + 1;
        $value = $v[1];
        switch ($v[0]) {
        case "M":
            $var_200 = $var_0[1];
            $size = $size + 4;
            $size = $size + \bin_prot\size\bin_size_int($var_200);
            break;
        case "N":
            $var_201 = $var_0[1];
            $size = $size + 4;
            break;
        default:
            throw new \bin_prot\exceptions\NoVariantMatch();
        }
    case "Z":
        $size = $size + 1;
        $value = $v[1];
        $var_100 = $value["m"];
        $var_101 = $value["n"];
        $size = $size + \bin_prot\size\bin_size_string($var_100);
        $size = $size + \bin_prot\size\bin_size_list('\bin_prot\size\bin_size_int', $var_101);
        return $size;
    default:
        throw new \bin_prot\exceptions\SumTag();
    }
    return $size;
}

class bin_t extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Complex\bin_read_t', '\Complex\bin_write_t', '\Complex\bin_size_t');
    }
}
