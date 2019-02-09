Get-Command -CommandType Cmdlet | 
  ForEach-Object { 
    $type = $_.ImplementingType
    if ($type -ne $null)
    {
      $type.GetCustomAttributes($true) | 
      Where-Object { $_.VerbName -ne $null } |
      Select-Object @{Name='Name';
      Expression={'{0}-{1}' -f $_.VerbName, $_.NounName}}, ConfirmImpact
    }
  } |
  Sort-Object ConfirmImpact -Descending 
