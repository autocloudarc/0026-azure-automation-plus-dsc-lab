Get-Help about_Functions_CmdletBindingAttribute -ShowWindow

$ConfirmPreference

Function Kill-Process
{
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
    Param([String]$Name)

    Process
    {
        $TargetProcess = Get-Process -Name $Name
        If ($pscmdlet.ShouldProcess($name, "Terminating Process"))
        {
            $TargetProcess.Kill()
        }
    }
} 

Start-Process notepad -WindowStyle Minimized
Kill-Process notepad -WhatIf
Kill-Process notepad
Kill-Process notepad -Confirm
Kill-Process notepad -Confirm:$false

$ConfirmPreference
# Change ConfirmImpact on line 7 to 'Medium'

Start-Process notepad -WindowStyle Minimized
Kill-Process notepad
Kill-Process notepad -Confirm
Kill-Process notepad -Confirm:$false
