<?php
$servername = "localhost";
$username   = "doubleks_clothhutadmin";
$password   = "pkhyokwdubc6";
$dbname     = "doubleks_clothhut";

$conn = new mysqli($servername, $username, $password, $dbname);
if($conn->connect_error){
    die("Connection failed: " . $conn->connect_error);
}
?>