cd $HOME\Documents\Demos

Set-PSBreakpoint -Script '7-Stepping.ps1' -Line 11
Set-PSBreakpoint -Script '7-Stepping.ps1' -Command Get-Acl
Set-PSBreakpoint -Script '7-Stepping.ps1' -Variable path -Mode ReadWrite

Get-PSBreakpoint

.\7-Stepping.ps1

Get-PSBreakpoint | Remove-PSBreakpoint -Confirm:$False

Set-PSBreakpoint -Script "*step*" -Variable log -Mode write -Action {Write-Host "*** LOG write $log ***" -ForegroundColor green}
Set-PSBreakpoint -Script "*step*" -Variable log -Mode read -Action {Write-Host "*** LOG read $log ***" -ForegroundColor yellow}

Get-PSBreakpoint | Remove-PSBreakpoint -Confirm:$False

Set-PSBreakpoint -Script "*step*" -Command Get-Acl -Action {Get-Variable > .\var.txt;break}

.\7-Stepping.ps1

Get-PSBreakpoint | Remove-PSBreakpoint -Confirm:$False
