
Function Test-Function {
param([string[]]$test)
$test
}

"Use 'Set-StrictMode -Version Latest' to flag issues in this script."
"'Set-PSDebug -Strict' will not flag as many issues in this script."

$Uninitialized

(Get-Process -Name Idle).InvalidProperty

Test-Function("hello","world")
