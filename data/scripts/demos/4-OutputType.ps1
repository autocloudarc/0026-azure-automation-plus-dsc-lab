function Test-Output 
{
[OutputType('String')]
param ($Name)
    “Hello, $Name!”
} #end function

Test-Output -Name Preston