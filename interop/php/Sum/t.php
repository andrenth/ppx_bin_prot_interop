<?php

use bin_prot\read;
use bin_prot\write;
use bin_prot\size;

namespace Sum;

function bin_read_t($buf, $pos) {
    switch (bin_read_int_8bit($buf, $pos)) {
    case 0:
        return array("A", null);
    case 1:
        list($var_100, $pos) = bin_read_int($buf, $pos);
        list($var_101, $pos) = bin_read_float($buf, $pos);
        $var_0 = array("x" => $var_100, "y" => $var_101);
        return array("B", $var_0);
    case 2:
        list($var_100, $pos) = bin_read_string($buf, $pos);
        list($var_101, $pos) = bin_read_char($buf, $pos);
        $var_0 = array($var_100, $var_101);
        return array("C", $var_0);
    case 3:
        return array("D", null);
    default:
        throw new SumTag();
    }
}

function bin_write_t($buf, $pos, $v) {
    $var_0 = $v;
    switch ($var_0[0]) {
    case "A":
        $pos = bin_write_int_8bit($buf, $pos, 0);
        return $pos;
    case "B":
        $pos = bin_write_int_8bit($buf, $pos, 1);
        $value = $var_0[1];
        $var_100 = $value["x"];
        $var_101 = $value["y"];
        $pos = bin_write_int($buf, $pos, $var_100);
        $pos = bin_write_float($buf, $pos, $var_101);
        return $pos;
    case "C":
        $pos = bin_write_int_8bit($buf, $pos, 2);
        $value = $var_0[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $pos = bin_write_string($buf, $pos, $var_100);
        $pos = bin_write_char($buf, $pos, $var_101);
        return $pos;
    case "D":
        $pos = bin_write_int_8bit($buf, $pos, 3);
        return $pos;
    default:
        throw new SumTag();
    }
    return $pos;
}

function bin_size_t($v) {
    $size = 0;
    $var_0 = $v;
    switch ($var_0[0]) {
    case "A":
        $size = $size + 1;
        return $size;
    case "B":
        $size = $size + 1;
        $var_100 = $var_0["x"];
        $var_101 = $var_0["y"];
        $size = $size + bin_size_int($var_100);
        $size = $size + bin_size_float($var_101);
        return $size;
    case "C":
        $size = $size + 1;
        $value = $var_0[1];
        $var_100 = $value[0];
        $var_101 = $value[1];
        $size = $size + bin_size_string($var_100);
        $size = $size + bin_size_char($var_101);
        return $size;
    case "D":
        $size = $size + 1;
        return $size;
    default:
        throw new SumTag();
    }
    return $size;
}

