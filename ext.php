<?php
$path = "imgs/";
if(!$path){
    echo "Error accessing {$path} directory!";
}

$files = scandir($path);
echo count($files);
foreach($files as $file){
    echo checkExt($file, "JPG") . "<br />";
}

function checkExt($file, $f_ext){
    if(!$file){
        echo 'No file supplied!';
    }

    $file = explode('.', $file);
    $ext = $file[1];

    if($ext == $f_ext){
        return true;
    } else {
        return false;
    }
}
?>