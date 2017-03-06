<?php

require_once("bin_prot/type_class.php");
require_once(__DIR__ . "/../_build/default/interop/php/Server/M/r.php");
require_once(__DIR__ . "/../_build/default/interop/php/Server/M/t.php");

use bin_prot\read as read;
use bin_prot\write as write;
use bin_prot\rpc as rpc;
use bin_prot\type_class as type_class;

function to_string($x) {
    if (!is_array($x))
        return "$x";
    $s = "array(";
    $i = 0;
    foreach ($x as $k => $v) {
        $sep = $i == 0 ? "" : ", ";
        $s .= "$sep$k => $v";
    }
    $s .= ")";
    return $s;
}

$sock = socket_create(AF_INET, SOCK_STREAM, 0);
if (!socket_connect($sock, "localhost", 8124))
    die("socket_connect: " . socket_last_error($sock) . "\n");

$conn = rpc\bin_rpc_client($sock, "my php client");
if (!$conn)
    die("bin_rpc_client\n");

$bin_t = new Server\M\bin_t();

$rpc = rpc\bin_rpc_create("M.t", 0, $bin_t, $bin_t);
if (!$rpc)
    die("bin_rpc_create\n");

$queries = array(
    "I" => 42,
    "S" => "abcd",
    "R" => array("i" => 42, "s" => "abcd"),
);

foreach ($queries as $k => $v) {
    $query = array($k, $v);
    list($tag, $value) = rpc\bin_rpc_dispatch($rpc, $conn, $query);
    $query_string = to_string($v);
    $value_string = to_string($value);
    echo "RPC ($k, $query_string) -> ($tag, $value_string)\n";
}
