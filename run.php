<?php

$inputOptions = getopt('i:o:');

if (!isset($inputOptions['i'])) {
    echo 'Must provide an input file.' . PHP_EOL;
    exit;
}
if (!isset($inputOptions['o'])) {
    echo 'Must provide an output file.' . PHP_EOL;
    exit;
}

$inputFile  = $inputOptions['i'];
$outputFile = $inputOptions['o'];

function processFile($filename) {

    if (!is_readable($filename)) {
        echo sprintf('Cannot find file "%s".', $filename) . PHP_EOL;
        exit;
    }

    $fileContents = file_get_contents($filename);

    // Single "include" command at the moment
    preg_match_all('/{{\s*(include)\s+([^\s]+)+\s*}}/i', $fileContents, $commandPart);

    if (count($commandPart) > 2) {
        $numberOfCommands = count($commandPart[0]);
        for ($commandNumber = 0; $commandNumber < $numberOfCommands; $commandNumber++) {
            $includedFilePath = dirname($filename) . '/' . $commandPart[2][$commandNumber];
            $fileContents = str_replace($commandPart[0][$commandNumber], processFile($includedFilePath), $fileContents);
        }
    }

    return $fileContents;
}

$generatedFileContents = processFile($inputFile);

echo sprintf('Creating output file "%s".', $outputFile) . PHP_EOL;
file_put_contents($outputFile, $generatedFileContents);