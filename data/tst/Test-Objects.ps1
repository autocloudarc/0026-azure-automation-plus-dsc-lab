class myclass
{
    $p1 = 0
    $p2 = 0
} # end class

$myObj = [myclass]::new()
[myclass[]]$myArr = @()

for ($i=1;$i -le 10;$i++)
{
    $myObj.p1 = $i
    $myObj.p2 = $i+1
    $myArr += $myObj
    $myArr
} # end for
