# https://azure.microsoft.com/en-us/documentation/articles/automation-dsc-compile/
# https://blogs.msdn.microsoft.com/powershell/2014/01/09/separating-what-from-where-in-powershell-dsc/
# https://social.msdn.microsoft.com/Forums/en-US/ccf2d18e-632b-46a8-b649-31be20dc0d22/dsc-with-xactivedirectory-verification-of-prerequisites-for-domain-controller-promotion-failed?forum=azureautomation
# https://blogs.technet.microsoft.com/markrenoden/2016/11/24/revisit-deploying-a-dc-to-azure-iaas-with-arm-and-dsc/

Configuration AddsCnfgAdatumDev
{
    [CmdletBinding()]

    Param (
        [string] $NodeName,
        [string] $domainName,
        [System.Management.Automation.PSCredential]$domainAdminCredentials
    ) # end param

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xStorage

    Node $AllNodes.Where{$_.Role -eq "DC"}.Nodename
    {
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
            ActionAfterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
        } # end LCM

        WindowsFeature DNS_RSAT
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
        } # end resource

        WindowsFeature ADDS_Install
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        } # end resource

        WindowsFeature RSAT_AD_AdminCenter
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-AdminCenter'
        } # end resource

        WindowsFeature RSAT_ADDS
        {
            Ensure = 'Present'
            Name   = 'RSAT-ADDS'
        } # end resource

        WindowsFeature RSAT_AD_PowerShell
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-PowerShell'
        } # end resource

        WindowsFeature RSAT_AD_Tools
        {
            Ensure = 'Present'
            Name   = 'RSAT-AD-Tools'
        } # end resource

        WindowsFeature RSAT_Role_Tools
        {
            Ensure = 'Present'
            Name   = 'RSAT-Role-Tools'
        } # end resource

        WindowsFeature RSAT_GPMC
        {
            Ensure = 'Present'
            Name   = 'GPMC'
        } # end resource

        xADDomain CreateForest
        {
            DomainName = $domainName
            DomainAdministratorCredential = $domainAdminCredentials
            SafemodeAdministratorPassword = $domainAdminCredentials
            DatabasePath = "C:\Windows\NTDS"
            LogPath = "C:Windows\LOGS"
            SysvolPath = "C:\Windows\Sysvol"
            DependsOn = '[WindowsFeature]ADDS_Install'
        }
    }
}