<?php

$inputOptions = getopt('i:o:');

if (!isset($inputOptions['i'])) {
    $inputFile = fopen('php://stdin', 'r');
} else {
    $inputFile  = $inputOptions['i'];
}

$output = null;
if (isset($inputOptions['o'])) {
    $output = $inputOptions['o'];
}


function processFile($filenameOrHandle) {

    if (!is_resource($filenameOrHandle)) {
        if (!is_readable($filenameOrHandle)) {
            echo sprintf('Cannot find file "%s".', $filenameOrHandle) . PHP_EOL;
            exit;
        }

        $dir = dirname($filenameOrHandle);
        $handle = fopen($filenameOrHandle, 'r');
    } else {
        $dir = getcwd();
        $handle = $filenameOrHandle;
    }

    $fileContents = stream_get_contents($handle);

    // Single "include" command at the moment
    preg_match_all('/{{\s*(include)\s+([^\s]+)+\s*}}/i', $fileContents, $commandPart);

    if (count($commandPart) > 2) {
        $numberOfCommands = count($commandPart[0]);
        for ($commandNumber = 0; $commandNumber < $numberOfCommands; $commandNumber++) {
            $includedFilePath = $dir . '/' . $commandPart[2][$commandNumber];
            $fileContents = str_replace($commandPart[0][$commandNumber], processFile($includedFilePath), $fileContents);
        }
    }

    return $fileContents;
}

$generatedFileContents = processFile($inputFile);

if (is_string($output)) {
    echo sprintf('Creating output file "%s".', $output) . PHP_EOL;
    file_put_contents($output, $generatedFileContents);
} else {
    echo $generatedFileContents;
}
