<?php

$api_response = $argv[1];

$parsed = json_decode($api_response, true);

echo $parsed['input']['size'];
echo "\t";
echo $parsed['output']['size'];
echo "\t";
echo $parsed['output']['ratio'];
echo "\t";
echo $parsed['output']['url'];

?>