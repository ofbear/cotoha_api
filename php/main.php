<?php
require('cotoha.php');

$c = new Cotoha("clientId", "clientSecret");
$result = $c->similarity("test", "test");

var_dump($result);

?>
