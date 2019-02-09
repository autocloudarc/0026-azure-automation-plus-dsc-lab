# This demo is so quick no clear advantage is perceived with three machines.

workflow Parallel-CIM {
param ($hostname)

    ForEach -Parallel ($PC in $hostname) {
        Get-CimInstance -ClassName Win32_BIOS -PSComputerName $PC
        Get-CimInstance -ClassName Win32_Volume -PSComputerName $PC
        Get-CimInstance -ClassName Win32_OperatingSystem -PSComputerName $PC
        Get-CimInstance -ClassName Win32_ComputerSystem -PSComputerName $PC
        Get-CimInstance -ClassName Win32_Product -PSComputerName $PC
    }

}


workflow Parallel-CIM2 {
    ForEach -Parallel ($Class in @('Win32_BIOS','Win32_Volume','Win32_OperatingSystem','Win32_ComputerSystem','Win32_Product')) {
        Get-CimInstance -ClassName $Class
    }
}



function Serial-CIM {
param ($hostname)

    ForEach ($PC in $hostname) {
        $c = New-CimSession -ComputerName $PC
        Get-CimInstance -ClassName Win32_BIOS -CimSession $c
        Get-CimInstance -ClassName Win32_Volume -CimSession $c
        Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $c
        Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $c
        Get-CimInstance -ClassName Win32_Product -CimSession $c
        Remove-CimSession $c
    }

}


Import-Module ActiveDirectory

$PCs = Get-ADComputer -Filter * | Select-Object -ExpandProperty DNSHostName

Parallel-CIM -hostname $PCs
(Measure-Command -Expression {Parallel-CIM -hostname $PCs}).TotalSeconds

Parallel-CIM2 -PSComputerName $PCs
(Measure-Command -Expression {Parallel-CIM2 -PSComputerName $PCs}).TotalSeconds

Serial-CIM -hostname $PCs
(Measure-Command -Expression {Serial-CIM -hostname $PCs}).TotalSeconds
