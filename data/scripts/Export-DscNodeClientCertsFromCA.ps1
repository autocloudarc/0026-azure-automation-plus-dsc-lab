# 1. https://chocolatey.org/install
using namespace System.Net
$webClientObj = [webclient]::new()
$installChocoUrl = 'https://chocolatey.org/install.ps1'
Invoke-Expression $webClientObj.DownloadString($installChocoUrl)
# choco feature enable -n allowGlobalConfirmation
# 2. https://chocolatey.org/packages/OpenSSL.Light
$openSSLLogPath = "C:\ProgramData\chocolatey\logs\chocolatey.log"
$openSSLInstallOkString = "The install of openssl.light was successful."
If (Get-Content -Path $openSSLLogPath | Select-String -Pattern $openSSLInstallOkString)
{
    # Upgrade OpenSSL toolkit
    choco upgrade openssl.light -y
} # end if
else
{
    choco install openssl.light -y
} # end else
# Update path env variable
$env:path += "C:\Program Files\OpenSSL\bin"
# 3. https://blogs.msdn.microsoft.com/alejacma/2012/04/13/how-to-export-issued-certificates-from-a-ca-programatically-powershell/
#Params 
<<<<<<< HEAD
 $strServer = "azrdev1001.dev.adatum.com"; 
 $strCAName = "eca01"; 
 $strPathForCerts = "F:\ca\cert\export"; 
=======
 $strServer = "<>"; 
 $strCAName = "<>"; 
 $strPathForCerts = "<>"; 
>>>>>>> master
 
 # Constants 
 $CV_OUT_BASE64HEADER = 0; 
 $CV_OUT_BINARY = 2; 
 $CV_OUT_CN = 10;
 
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
            } # end contingency 
            <#
            "Issued Common Name"
            {
                $objValue = $objCertViewColumn.GetValue($CV_OUT_CN)
                if ($objValue -ne $null)
                {
                    $strCN = $objValue + ".cer"
                } # end if
            } # end contingency
            #>
            "Binary Certificate"
            {
                # Binary Certificate 
                $objValue = $objCertViewColumn.GetValue($CV_OUT_BASE64HEADER); 
                if ($objValue -ne $null) 
                { 
                    # Write certificate to file 
                    $strPath = $strPathForCerts + "\" + $strID + ".cer"
                    Set-Content -Path $strPath -Value $objValue
                } # end if
                break
            } # end contingency
            default {}
        } # end switch
    } # end while
 } # end for
 Write-Host "We are done!`nCerts have been copied to: $strPathForCerts"
 pause
<<<<<<< HEAD
 Start-Process -FilePath explorer -ArgumentList F:\ca\cert\export
 # $subjectName = (openssl x509 -in "F:\ca\cert\export\Request ID 13.cer" -noout -text | Select-String -Pattern "dns:azrweb1001").ToString().Split(":")[1]
=======
 Start-Process -FilePath explorer -ArgumentList <>
 # $subjectName = (openssl x509 -in "..\*.cer" -noout -text | Select-String -Pattern "dns:azrweb1001").ToString().Split(":")[1]
>>>>>>> master
