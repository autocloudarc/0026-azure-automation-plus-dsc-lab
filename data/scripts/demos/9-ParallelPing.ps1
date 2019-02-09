workflow Parallel-Ping {
param ($hostname)
    ForEach -Parallel ($PC in $hostname) {
        Test-Connection -ComputerName $PC
    }
}

function Serial-Ping {
param ($hostname)
    ForEach ($PC in $hostname) {
        Test-Connection -ComputerName $PC
    }
}


Import-Module ActiveDirectory

$PCs = Get-ADComputer -Filter * | Select-Object -ExpandProperty DNSHostName

Serial-Ping -hostname $PCs
(Measure-Command -Expression {Serial-Ping -hostname $PCs}).TotalSeconds

Parallel-Ping -hostname $PCs
(Measure-Command -Expression {Parallel-Ping -hostname $PCs}).TotalSeconds
