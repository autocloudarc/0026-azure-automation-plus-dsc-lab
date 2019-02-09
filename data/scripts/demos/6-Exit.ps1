for ($a=1;$a -lt 10;$a++) {
    $a
    If ($a -eq 5) {exit 66}
}

$LASTEXITCODE
$?

