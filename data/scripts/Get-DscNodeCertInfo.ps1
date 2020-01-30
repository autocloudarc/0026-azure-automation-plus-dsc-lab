# https://blogs.msdn.microsoft.com/alejacma/2012/04/13/how-to-export-issued-certificates-from-a-ca-programatically-powershell/
# http://www.jamesbannanit.com/2015/03/bulk-request-and-export-client-certificates-with-powershell/
# https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/certutil
# Select target node to configure by looking for the 01 series DC patter for dev.adatum.com the .. represents a 2 digit number that can vary by deployments
$targetNode = (Get-ADComputer -Filter *).DNSHostName | Where-Object {$_ -match 'azrweb..01'}
# Get list of resources required for this configuration so that can be copied to the target node
$dscResourceList = @("xActiveDirectory", "xComputerManagement", "xStorage", "xPendingReboot")
# Create a session to prepare the target node, i.e Install pre-requisite features 
$targetNodeSession = New-PSSession -Name $targetNode
# Obtain local source and remote destination resource modules paths to copy resources to target node
$resourceModulePath = $env:PSModulePath -split ";" | Where-Object {$_ -match 'C:\\Program Files\\WindowsPowerShell'}
$targetModulePaths = (Get-ChildItem -Path $resourceModulePath -Directory | Where-Object {$_.Name -in $dscResourceList}).FullName
$uncTargetPath = $resourceModulePath.Replace('C:\',"\\$targetNode\C$\")
#endregion
$exportDirName = "TempClientCertExport"
$remoteCertExportPath = "\\" + $targetNode + "\c$\$exportDirName"
If (-not(Test-Path -Path $remoteCertExportPath))
{
    Try
    {
        New-Item -Path $remoteCertExportPath -ItemType Directory -Verbose
    } # end try
    catch 
    {
        Write-Output "Error creating the remote path $remoteCertExportPath"
        Write-Output "Error exception $error[0].Exception"
    } # end catch
    finally
    {
        Write-Host "Teminating script"
        Exit-PSSession
    } # end finally
} # end if
else
{
    Write-Output "The target path: $remoteCertExportPath ALREADY EXIST. Skipping creation."
} # end else

# Copy resources to target node
ForEach ($targetModulePath in $targetModulePaths)
{
    Copy-Item -Path $targetModulePath -Destination $uncTargetPath -Recurse -Verbose -Force
} # end for

$localCertStorePath = 'cert:\localmachine\my'
$output = Invoke-Command -Session $targetNodeSession -ScriptBlock { 
    $certCER = Get-ChildItem -Path $using:localCertStorePath -Recurse | Where-Object {($_.Issuer -match 'eca01') -and ($_.EnhancedKeyUsageList -match 'Client Authentication')}
    $certCER.Thumbprint
    $localCertExportPath = "$env:SystemDrive\$using:exportDirName"
    If (Test-Path -Path $localCertExportPath)
    {
            Export-Certificate -Cert $certCER -Type CERT -FilePath (Join-Path -Path $localCertExportPath -ChildPath ($using:targetNode + ".cer")) | Out-null
    } # end if
    Install-PackageProvider -Name NuGet -Force
	Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-WindowsFeature -Name Dsc-service
} # end scriptblock

$output
$remoteCertFileName = (Get-ChildItem -Path $remoteCertExportPath -File -Filter "$targetNode.cer").FullName
$remoteCertFileName

Remove-PSSession -Session $targetNodeSession 

#region main

#endregion 