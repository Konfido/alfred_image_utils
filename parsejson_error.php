<?php

$api_response = $argv[1];

$parsed = json_decode($api_response, true);

echo $parsed['error'];
echo "\t";
echo $parsed['message'];

?>