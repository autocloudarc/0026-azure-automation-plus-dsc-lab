
Function Show-Access {
param($Path)
        Get-ACL -Path $Path | Select-Object -ExpandProperty Access | ft -AutoSize
}


Function Get-ACLRecursiveFiles {
param($Path)

    $logs = Get-ChildItem $Path -Recurse -File
    ForEach ($log in $logs) {
        "`n`n$($log.FullName)`n`n"
        Show-Access -Path $log.FullName
    }

}

# Set a breakpoint on the line below
"Practice stepping over, into, out"

Get-ACLRecursiveFiles -Path C:\Windows\Logs

"Done"
