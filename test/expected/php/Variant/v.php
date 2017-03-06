<?php

namespace Variant;

function bin_read_v($buf, $pos) {
    try {
        list($v, $pos) = bin_read_u($buf, $pos);
        return array($v, $pos);
    }
    catch (\bin_prot\exceptions\NoVariantMatch $e) {
        try {
            list($v, $pos) = bin_read_t($buf, $pos);
            return array($v, $pos);
        }
        catch (\bin_prot\exceptions\NoVariantMatch $e) {
            list($vint, $pos) = \bin_prot\read\bin_read_variant_int($buf, $pos);
            $v = "__dummy__";
            switch ($vint) {
            case 89:
                $v = array("Y", null);
                break;
            default:
                throw new \bin_prot\exceptions\NoVariantMatch();
            }
            return array($v, $pos);
        }
        return array($v, $pos);
    }
}

function bin_write_v($buf, $pos, $v) {
    try {
        $pos = bin_write_u($buf, $pos, $v);
        return $pos;
    }
    catch (\bin_prot\exceptions\NoVariantMatch $e) {
        try {
            $pos = bin_write_t($buf, $pos, $v);
            return $pos;
        }
        catch (\bin_prot\exceptions\NoVariantMatch $e) {
            switch ($v[0]) {
            case "Y":
                $var_202 = $v[1];
                $pos = \bin_prot\write\bin_write_variant_int($buf, $pos, 89);
                break;
            default:
                throw new \bin_prot\exceptions\NoVariantMatch();
            }
            return $pos;
        }
        return $pos;
    }
    return $pos;
}

function bin_size_v($v) {
    $size = 0;
    try {
        $size = $size + bin_size_u($v);
        return $size;
    }
    catch (\bin_prot\exceptions\NoVariantMatch $e) {
        try {
            $size = $size + bin_size_t($v);
            return $size;
        }
        catch (\bin_prot\exceptions\NoVariantMatch $e) {
            switch ($v[0]) {
            case "Y":
                $var_202 = $v[1];
                $size = $size + 4;
                break;
            default:
                throw new \bin_prot\exceptions\NoVariantMatch();
            }
            return $size;
        }
        return $size;
    }
    return $size;
}

class bin_v extends \bin_prot\type_class\type_class {
    public function __construct()
    {
        parent::__construct('\Variant\bin_read_v', '\Variant\bin_write_v', '\Variant\bin_size_v');
    }
}
