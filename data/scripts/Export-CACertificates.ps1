# https://blogs.msdn.microsoft.com/alejacma/2012/04/13/how-to-export-issued-certificates-from-a-ca-programatically-powershell/

#Params 
$strServer = "<>"
$strCAName = "eca"
$strPathForCerts = "..\certs"

# Constants 
$CV_OUT_BASE64HEADER = 0; 
$CV_OUT_BINARY = 2; 

# Connecting to the Certificate Authority 
$objCertView = New-Object -ComObject CertificateAuthority.View
$objCertView.OpenConnection($strServer + "\" + $strCAName)

# Get a column count and place columns into the view 
$iColumnCount = $objCertView.GetColumnCount(0)
$objCertView.SetResultColumnCount($iColumnCount)

# Place each column in the view
for ($x=0; $x -lt $iColumnCount; $x++)
{
    $objCertView.SetResultColumn($x)
} # end for

# Open the View and reset the row position 
$objCertViewRow = $objCertView.OpenView(); 
$objCertViewRow.Reset(); 

# Enumerate Row and Column Information 
# Rows (one per cert) 
for ($x = 0; $objCertViewRow.Next() -ne -1; $x++) 
{ 
    # Columns with the info we need 
    $objCertViewColumn = $objCertViewRow.EnumCertViewColumn() 
    while ($objCertViewColumn.Next() -ne -1) 
    { 
        switch ($objCertViewColumn.GetDisplayName()) 
        { 
            "Request ID"
            {
                #Request ID 
                $objValue = $objCertViewColumn.GetValue($CV_OUT_BINARY)
                if ($objValue -ne $null) 
                { 
                    $strID = "Request ID " + $objValue
                } # end if
                break
            } # end request id

            "Binary Certificate"
            {
                # Binary Certificate 
                $objValue = $objCertViewColumn.GetValue($CV_OUT_BASE64HEADER); 
                if ($objValue -ne $null) 
                { 
                    # Write certificate to file 
                    $certName = $strID + ".cer"
                    $strPath = Join-Path $strPathForCerts -ChildPath $certName
                    Set-Content $strPath $objValue
                } # end if
                break
            } # end binary certificate
            default 
            {
            } # end default
        } # end switch 
    } # end while
} # end for

Write-Host "We are done!`nCerts have been copied to " + $strPathForCerts

$certFiles = Get-ChildItem -Path $strPathForCerts -File 

class certs 
{
    [string]$DnsName = $null
    [string]$thumbPrint = $null
    [string]$FullPath = $null
} # end class

$statusList = @()

ForEach ($certFile in $certFiles)
{
    $cert = Get-PfxCertificate -FilePath $certFile.FullName 
    $docEncCerts = $cert | Where-Object { $_.EnhancedKeyUsageList -match 'Document Encryption'}
    $statusObj = [certs]::new() 
    If ($docEncCerts.DnsNameList)
    {
        $statusObj.DnsName = $docEncCerts.DnsNameList[0]
    } # end 
    $statusObj.thumbPrint = $docEncCerts.Thumbprint
    If ($docEncCerts.EnHancedKeyUsageList -match 'Document Encryption')
    {
        $statusObj.FullPath = $certFile.FullName
    } # end if
    $statusList += $statusObj
} # end foeach
$statusList
