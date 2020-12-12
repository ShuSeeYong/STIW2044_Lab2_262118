<?php
    error_reporting(0);
    include_once("dbconnect.php");
    $email = $_GET['email'];
    $otp = $_GET['key'];
    
    $sql = "SELECT * FROM USER WHERE EMAIL = '$email'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        $sqlupdate = "UPDATE USER SET OTP = '0' WHERE EMAIL = '$email' AND OTP = '$otp'";
        if ($conn->query($sqlupdate) === TRUE){
            echo 'Successful Register. Welcome to Clothhut Application! Now you can login to Clothhut Application! Thank You for Register it!';
        }else{
            echo 'failed';
        }   
    }else{
        echo "failed";
    }
?>
