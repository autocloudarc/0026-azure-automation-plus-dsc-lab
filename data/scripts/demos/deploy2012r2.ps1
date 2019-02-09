<#
****************************************************************************************************************************************************************************
PROGRAM		:Deploy2012r2.ps1
STATUS      :RELEASED
SYNOPSIS	:Configures a new virtual or physical deployment of Windows Server 2012/ Windows Server 2012 R2 operating system.
DESCRIPTION	:This script is used by the <> team to automate many of the routine, predictable and repeatable tasks required to deploy a Windows Server 2012/2012 R2 machine
            :with <> standard configuration.
PARAMETERS	:$hostname, $OS, $PhyMem, $DataCenter, $Zone, $Layer, $Center, $Application, $AppID, $ProdIP, $MGTIP, $BURIP, $Serial, $Barcode, $Reboot, $IsVMware, $IsCitrix  
INPUTS		:See PARAMETERS 
OUTPUTS		:<HOSTNAME>.<MM-DD-YYYY>-Deploy2012.log
EXAMPLES	:FDSWP00001.MM-DD-YYYY-Deploy2012.log, FDSWV00001.MM-DD-YYYY-Deploy2012.log
REQUIREMENTS:1. Windows Server 2012 or 2012 R2 Operating System, PowerShell Version 2.0. 
            :2. This script must be executed in the context of a local administrative account using RunAs.
LIMITATIONS	:TBD 
AUTHOR(S)	:Preston K. Parsard <Company> <Email>
EDITOR(S)	:<Name> <Company> 	<Email>
REFERENCES	:http://mcpmag.com/articles/2014/03/18/required-scripting-parameters.aspx
            :http://www.microsoft.com/en-us/download/confirmation.aspx?id=40855
            :http://technet.microsoft.com/en-us/magazine/jj554301.aspx
            :http://powershell.com/cs/forums/p/13561/25041.aspx
            :http://dnsshell.codeplex.com/
            :http://powershell.com/cs/forums/p/16375/36311.aspx
            :http://support.microsoft.com/kb/934307
KEYWORDS	:Deploy, Configure
****************************************************************************************************************************************************************************
#>

<# WORK ITEMS
TASK-INDEX: 005 Get clarification for password complexity setting
TASK-INDEX: 011 Move server admin group to <>DataCenter ? [RFC]
TASK-INDEX: 034 Could not create PTR record for <hostname>-bur
TASK-INDEX: 035 [FIXED]? logic to register -MGT interface in DNS for servers not in the MGT zone
TASK-INDEX: [FIXED?] Check FW service. If running, stop and disable.
TASK-INDEX: [FIXED?] Check Print Spooler service. If running, stop and disable.
TASK-INDEX: [FIXED?] Check Windows Installer service startup type. If not set to manual, set to manual.
TASK-INDEX: Fix adding server group to local administrators task by creating a new [ADSI] based function
#>

#***************************************************************************************************************************************************************************
# REVISION/CHANGE RECORD	
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# DATE        VERSION  INI CHANGE
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# 12 SEP 2014 1.0.0000 PKP Initial release to accept parameters from front end and to initiate logging 
# 01 OCT 2014 1.0.0001 PKP Changed "Local Disk" drive label for drive letter "C" to "SYSTEM"
# 01 OCT 2014 1.0.0002 PKP Tested DnsShell utility; Unable to load module with this combination of .NET 4.5 and PowerShell 4.0 
# 01 OCT 2014 1.0.0003 PKP Removed the Reboot parameter.
# 01 OCT 2014 1.0.0004 PKP Changed "$Enclave" parameter to "$Layer"
# 01 OCT 2014 1.0.0005 PKP Removed check for no parameters passed, since parameters are configured as mandatory
# 01 OCT 2014 1.0.0006 PKP Changed $Citrix boolean parameter to $IsCitrix for consistency with other boolean parameters
# 01 OCT 2014 1.0.0007 PKP Checked for ActiveDirectory module; NA - Uses implicit remoting via the Active Directory Web Services
# 01 OCT 2014 1.0.0008 PKP Changed "Local Disk" drive label for drive letter "C" to "SYSTEM"
# 01 OCT 2014 1.0.0009 PKP Removed unused directory and file path variables
# 01 OCT 2014 1.0.0010 PKP Added code to test for EPO Agent GUID entry and delete if present
# 01 OCT 2014 1.0.0011 PKP Changed instances of Win32_Product queries to registry checks (faster method of checking for apps)       
# 01 OCT 2014 1.0.0012 PKP Removed logging option from $MsiArgs variable to prevent overwriting previous log entries          
# 01 OCT 2014 1.0.0013 PKP Added $HostnameBUR variable to append -BUR to hostname for BUR interface
# 01 OCT 2014 1.0.0015 PKP Debugged and enhanced NetBackup installation
# 01 OCT 2014 1.0.0016 PKP Debugged and enhanced ePO installation
# 02 OCT 2014 1.0.0017 PKP Parsard Debugged Mandiant installation to fix multiple installation operations even when it is already installed
# 02 OCT 2014 1.0.0018 PKP Debugged SCCM installation by updating pRemoteSccmFile = "..SCCM (64BitOS).bat"
# 02 OCT 2014 1.0.0019 PKP Corrected installation path for NetIQ Agent and Module
# 02 OCT 2014 1.0.0020 PKP Fixed SCCM installation
# 02 OCT 2014 1.0.0021 PKP Added reboot prompt to complete removal of DNS Tools feature at end of script
# 14 OCT 2014 1.0.0022 PKP Added pause statement before exiting script
# 16 OCT 2014 1.0.0023 PKP Offer option to open log file at end of script. Added statements to prompt for opening log
# 16 OCT 2014 1.0.0024 PKP Fix N and P mappings to install NBU and NBU patch. Removed -NoNewWindow parameter
# 16 OCT 2014 1.0.0025 PKP Fix creation and addition of srvradmin-<hostname> to local administrative groups added using net localgroup command [pending]
# 16 OCT 2014 1.0.0026 PKP Record current EPO AgentGUID in log for future reference before reseting it to null [FIXED?] added GUID [pending]
# 16 OCT 2014 1.0.0027 PKP Check SCCM not installing.Specified -WorkingDirectory parameter
# 16 OCT 2014 1.0.0030 PKP Remove the AD tools to reduce the attack surface [FIXED?] Addded the Uninstal statement at end of script
# 16 OCT 2014 1.0.0031 PKP Fixed parameter value to perform the WMF4 upgrade. Correct path is:   pWUSAPath = "C:\Windows\System32\wusa.exe"
# 16 OCT 2014 1.0.0032 PKP Removed the ProdIP, MGTIP, and BURIP ToUpper statements since these are just numbers anyway.
# 16 OCT 2014 1.0.0033 PKP Updated logic to review parameter summary and continue script execution
# 16 OCT 2014 1.0.0034 PKP changed "-BUR" suffix to "-bur" for DNS registration to accomodate lowercase format for netbackup operation
# 16 OCT 2014 1.0.0035 PKP Commented out NetBackup and SCCM checks and installations. Archived commented out version in SVN in case it will be needed in the future.
# 16 OCT 2014 1.0.0036 PKP Fixed registrtaion of <hostname>-MGT A and PTR records. IPv4 variable value was null.
# 22 OCT 2014 1.0.0037 PKP Changed log file name prefix from Deploy2012 to Deploy2012-2012r2
# 27 OCT 2014 1.0.0038 PKP Enabled Powershell Remoting (Enable-PSRemoting -Force)
# 27 OCT 2014 1.0.0039 PKP Set bcdedit timeout value to 3. (invoke-command { bcdedit /timeout 3 })
# 04 NOV 2014 1.0.0040 PKP Removed (commented out) the Mandiant (MIR) installation, because the SCCM team will be deploying a new version. Requested by Soohun Ha.
# 05 NOV 2014 1.0.0041 PKP Added check for SNMP service feature, which installs and starts the service if it is not already installed and started
# 05 NOV 2014 1.0.0042 PKP Check Windows Firewall, Print Spooler and Windows Installer services. Stops and disabled Firewall and Print Spooler services, and sets Installer startup type to manual.
# 06 NOV 2014 1.0.0043 PKP Fix adding server admin group to local adminstrators group
# 07 NOV 2014 1.0.0044 PKP Changed $Serial and $Barcode parameters to default values of "0"
# 07 NOV 2014 1.0.0045 PKP Check Remote Registry service and starts it if necessary. Also changed the startup type to Auto if it is not already set
# 11 NOV 2014 1.0.0046 PKP Corrected conditional statements to check for presence of DNS server tools and AD Module for PowerShell feature.
# 11 DEC 2014 1.0.0059 PKP Reversed the order of layer - zone in the computer object description field stamp so that the zone disgnation (TST|DEV|PRD) will preceed the layer (PRE|APP|DTA) values.

#*******************
# INITIALIZE VALUES
#*******************
#region Initialize

# Grab All Arguments into Varibles.

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
   [string]$hostname, # Name of server
	
   [Parameter(Mandatory=$True)]
   [string]$OS, # Operating System [Win2012/Win2012R2]

   [Parameter(Mandatory=$True)]
   [string]$PhyMem, # Amount of RAM in GB

   [Parameter(Mandatory=$True)]
   [string]$DataCenter, # Data center location [<>DataCenter/<>DataCenter2/<>DataCenter3]

   [Parameter(Mandatory=$True)] 
   [string]$Zone, # Development, Test, Production...[DEV/TST/PRD/MGT/ORG]

   [Parameter(Mandatory=$True)]
   [string]$Layer, # Layer; Presentation, Application, Data...[PRE/APP/DATA/DMZ/SHA/MPR/ORG]

   [Parameter(Mandatory=$True)]
   [string]$Center, # Center [OC/CENTER2/CENTER3/CDER,CENTER5,etc]

   [Parameter(Mandatory=$True)]
   [string]$Application, # Application description [IIS/EROOM/EPO,etc]

   [Parameter(Mandatory=$True)]
   [string]$AppID, # Application ID [000-999]

   [Parameter(Mandatory=$False)]
   [string]$ProdIP, # Production IP [aaa.bbb.ccc.ddd]

   [Parameter(Mandatory=$True)]
   [string]$MGTIP, # Management IP [aaa.bbb.ccc.ddd]

   [Parameter(Mandatory=$True)]
   [string]$BURIP, # Backup and Recovery IP [aaa.bbb.ccc.ddd]

   [Parameter(Mandatory=$False)]
   [string]$Serial = "0", # Server Serial Number       

   [Parameter(Mandatory=$False)]
   [string]$Barcode = "0", # ORG Barcode

   [Parameter(Mandatory=$True)]
   [string]$IsVMware, # Is server virtual? [True/False]

   [Parameter(Mandatory=$True)]
   [string]$IsCitrix # Will server be part of the Citrix infrastructure? [True/False]
) #end param

#endregion Initialize

#***********************
# FUNCTIONS	
#***********************

# Convert string parameters to upper case
Function Convert-StringParamsToUpper
{
 $hostname = $hostname.ToUpper()
 $OS = $OS.ToUpper()
 $PhyMem = $PhyMem.ToUpper()
 $DataCenter = $DataCenter.ToUpper()
 $Zone = $Zone.ToUpper()
 $Layer = $Layer.ToUpper()
 $Center = $Center.ToUpper()
 $Application = $Application.ToUpper()
 $AppID = $AppID.ToUpper()
 $Serial = $Serial.ToUpper()
 $Barcode = $Barcode.ToUpper()
 $IsVMware = $IsVMWare.ToUpper()
 $IsCitrix = $IsCitrix.ToUpper()
} #end Convert-StringParamsToUpper

# Send output to both the console and log file
Function ShowAndLog
{
[CmdletBinding()] Param([Parameter(Mandatory=$True)]$Output)
$Output | Tee-Object -FilePath $FilesObj.pLog -Append
} #end ShowAndLog

# Send output to both the console and log file and include a time-stamp
Function LogWithTime
{
[CmdletBinding()] Param([Parameter(Mandatory=$True)]$LogEntry)
# Construct log time-stamp for indexing log entries
 # Get only the time stamp component of the date and time, starting with the "T" at position 10
$TimeIndex = (get-date -format o).ToString().Substring(10)
$TimeIndex = $TimeIndex.Substring(0,17)
"{0}: {1}" -f $TimeIndex,$LogEntry | Tee-Object -FilePath $FilesObj.pLog -Append
# $Output | Tee-Object -FilePath $FilesObj.pLog -Append
} #end LogWithTime

# Send output to log file only
Function LogToFile
{
[CmdletBinding()] Param([Parameter(Mandatory=$True)]$LogData)
$LogData | Out-File -FilePath $FilesObj.pLog -Append
} #end LogToFile

#***********************
# CONFIGURATION DATA
#***********************

# DIRECTORIES (DirsObj)
# Populate directories object 
# Add properties and values 
 $DirsObj = [PSCustomObject]@{
  # Non-Citrix enabled directories
  pSoftwarePath = "\\ORG.gov\<>DataCenter\oc\OIM\DOI\TO2\Windows\Deployment\Software"
  pLocalSW = "C:\Software"
  pDeployPath = "\\ORG.gov\<>DataCenter\oc\OIM\DOI\TO2\Windows\Deployment\DeploymentScript"
  pLogPath = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Common\DCSERVICESTEAM\TO1_TO_TO2_TURNOVER\SERVER\WINDOWS\DEPLOY_LOGS"
  pPrgmFilesX86 = "C:\Program Files (x86)"
  pEmetDir = "\\ORG.gov\<>DataCenter\oc\oim\doi\TO2\Windows\Software\Microsoft\EMET"
  # TASK-ITEM: pLocalSecurityPolicy = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Deployment\Software\Security"

  pInstallDirNetIQx64 = "C:\Program Files (x86)\NetIQ\"
  pWMF4Path = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\Microsoft\WindowsManagementFramework4.0"
  pNBUx64ClientRemPath = "\\fdswp00301\x$\Software\NetBackup_7.6.0.1_Win\PC_Clnt\x64"
  pNBUx64PatchRemPath = "\\fdswp00301\x$\Software\NetBackup_7.6.0.1_Win\_NB_7.6.0.2.winnt.x64"
  # Citrix enabled directories
  pctxLogPath="\\tsclient\T\Common\DCSERVICESTEAM\TO1_TO_TO2_TURNOVER\SERVER\WINDOWS\DEPLOY_LOGS"
  pctxSoftwarePath="\\tsclient\T\Windows\Deployment\Software"
  pctxDeployPath="\\tsclient\T\Windows\Deployment\DeploymentScript"
  pctxPsToolsPath="\\tsclient\T\Common\DCSERVICESTEAM\DOWNLOADS\PsTools"
  pctxVSERemotePath="\\tsclient\T\TO2_Windows_Team\Deployment\Software\8.7"
  pctxEpoAgentRemotePath="\\tsclient\T\TO2_Windows_Team\Deployment\Software\EPO Agent"
  pctxLocalSecurityPolicy="\\tsclient\T\TO2_Windows_Team\Deployment\Software\Security"
  pctxMIRRemotePath="\\tsclient\T\TO2_Windows_Team\Deployment\Software\MIR\MIR 1.4 Agent"
  pctxHostFilePath="\\tsclient\N"
 } #end $DirsObj

# Construct log file from hostname and current date/time
$TimeStamp = (get-date -format u).Substring(0,16)
$TimeStamp = $TimeStamp.Replace(" ", "-")
$TimeStamp = $TimeStamp.Replace(":", "")

$LogFile = "Deploy2012-2012r2" + $hostname + "-" + $TimeStamp + ".txt"
$Log = Join-Path -Path $DirsObj.pLogPath -ChildPath $LogFile

# MSI installation arguments
$MsiArgs = "/qn"

# Timeout value
$tov = 3

# Use current logon server Domain Controller for DNS operations
$DnsSvr = $env:LOGONSERVER.Replace("\\","") + ".ORG.gov"

# Create and populate files object with property-value pairs
# FILES (FilesObj)
  $FilesObj = [PSCustomObject]@{
   pUnattendPhys2k8 = "C:\Windows\System32\sysprep\unattend.xml"
   pWMF4File = "Windows8-RT-KB2799888-x64.msu"
   pWUSAPath = "C:\Windows\System32\wusa.exe"
   # NetIQ Installation Paths
   pSrcNetIQAgentMSI = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\NetIQ\AppManager\Agent\NetIQ AppManager agent.msi"
   pSrcNetIQWinOSMSI = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\NetIQ\AppManager\Modules\AM70_WinOS_7.8.94.0\AM70-WinOS-7.8.94.0.msi"
   pMIRRemotePath = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Deployment\Software\MIR\MIR 1.4 Agent\AgentSetup.msi"
   # McAfee VSE
   pRemVse = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\McAfee\8.8 P4\VSE880LMLRP4\SetupVSE.Exe"
   pRemVsePatch = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\McAfee\8.8 P4\Patch 4\Setup.exe"
   pRemVseHF = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\McAfee\8.8 P4\8.8 Hot Fix 805660\VSE88HF805660.exe"
   # McAfee EPO 
   pEpoAgentRemFile<>DataCenter = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\McAfee\EPO Agent\<>DataCenter\FramePkgMGMT.exe"
   pEpoAgentRemFileNot<>DataCenter = "\\ORG.gov\<>DataCenter\OC\OIM\DOI\TO2\Windows\Software\McAfee\EPO Agent\CENTER5 & <>DataCenter3\FramePkgMain.exe"
   pLog = $Log
  } #end $FilesObj

# Create and populate OU paths object with property-value pairs
# OU (OUPathsObj)
$OUPathsObj = [PSCustomObject]@{
 pSvrAdmGrpOU = "ou=DC-Metro,ou=Server,ou=Groups,dc=ORG,dc=gov"
} #end $OUPathsObj

# Create and populate registry paths object with property-value pairs 
# REGISTRY (RegPathsObj)
$RegPathsObj = [PSCustomObject]@{
 pNBUCurrVer = "HKLM:\SOFTWARE\VERITAS\NetBackup\CurrentVersion"
 pNBUConfigKey = "HKLM:\Software\Veritas\NetBackup\CurrentVersion\Config"
 pNetIQAgent = "HKLM:\SOFTWARE\Wow6432Node\NetIQ\AppManager\ComponentSummary\Agent"
 pNetIQAMFW = "HKLM:\SOFTWARE\Wow6432Node\NetIQ\AppManager\ComponentSummary\Module_Uninstall_WinOS.exe"
 pAvEngine = "HKLM:\SOFTWARE\Wow6432Node\McAfee\DesktopProtection"
 pAvAgent = "HKLM:\SOFTWARE\Wow6432Node\Network Associates\ePolicy Orchestrator\Agent"
} #end $RegPathsObj 

# Create and populate registry keys object with property-value pairs 
# REGISTRY (RegKeysObj)
$RegKeysObj = [PSCustomObject]@{
 pName = "Name"
 pVSE = "CoreRef"
} #end $RegKeysObj

# Create and populate registry values object with property-value pairs 
# REGISTRY (RegValsObj)
$RegValsObj = [PSCustomObject]@{
 pNetIQAgent = "NetIQ AppManager agent"
 pNetIQAMFW = "AppManager for Windows"
 pVseCoreRef = "VSE88P4"
} #end $RegValsObj

# Create and populate messages object with property-value pairs
# MESSAGES (MsgsObj)
$MsgsObj = [PSCustomObject]@{
 pOriginalForeground = "Green"
 pEmphasisForeground = "Yellow"
 pRestartComment = "RSAT Tools installation or removal - Reboot Required..."
 pUseDeploymentFE = "Please execute the deployment front end component DeploymentFrontend.exe..."
 pCfgServer = "Beginning server configuration..."
 pSvrGrpDesc = "ORG Server Group Membership for local administrators..."
 pSplitMGTIP = "Parsing MGT IP into octets for subsequent DNS PTR registration..."
 pSplitBURIP = "Parsing BUR IP into octets for subsequent DNS PTR registration..."
 pCheckSvrDesc = "Checking server description property in AD..."
 pApplySvrDesc = "Server description property not set. Applying description property now..."
 pSvrDescAlreadySet = "Server description property was already set. Skipping..."
 pHdrTop = "======================================================================================="
 pHeader = "WINDOWS 2012/2012 R2 SERVER DEPLOYMENT STAGING SUMMARY " + $TimeStamp
 pHdrLow = "======================================================================================="
 pCheckForSvrAdminGrp = "Checking for Server Admin AD group..." 
 pAddADGroup = "Server Admin AD group not added. Adding now..."
 pADGroupAlreadyExist = "Server Admin AD group already exist. Skipping..."
 pImportDNSMod = "Importing custom DNS PowerShell module from shared directory..."
 pCheckPSver = "Checking for PowerShell 4.0 version..."
 pPSverNot4a = "PowerShell Version 4.0 is not installed. Installing Windows Management Framework 4.0 components (WinRM, WMI and PowerShell 4.0)..."
 pPSverNot4b = "Follow the standalone installer prompts to complete the installation. NOTE: A REBOOT WILL BE AUTOMAICALLY PERFORMED, even if you press the NO button from the installer"
 pPSverNot4c = "The reboot is required because the DNS cmdlets to register the DNS records is only available in PowerShell 4.0 and later."
 pPSverNot4d = "Once the server has rebooted, please execute DeploymentFrontend.exe again to continue..."
 pPSverIs4 = "PowerShell Version 4 is already installed. Skipping..."
 pSystemDriveLabel = "SYSTEM"
 pCheckForDnsTool = "Checking to see if the DNS Server Tools feature is installed..."
 pInstallDnsTool = "DNS Tools Feature is available; Installing..."
 pCheckAndLoadDnsMod = "Checking if DnsServer module is installed or loaded. If installed but not loaded, then load (import) module..."
 pImportDnsSvrModule = "Imorting DnsServer module..."
 pDnsSvrModNA = "DnsServer module not available..."
 pDnsModLoaded = "DnsServer module already loaded. Skipping..."
 pUpdateHelp = "Updating help files..."
 pDnsToolInstalled = "DNS Tools Feature has already been installed; Skipping..." 
 pRemoveDnsTool = "Removing the DNS server tools to reduce the attack surface of currently configured server..."
 pRemoveADTools = "Removing the AD server tools to reduce the attack surface of currently configured server..."
 pChkNONpriIP = "Checking the non primary interfaces (MGT if applicable and BUR) for DNS registration..."
 pMGTisPrimary = "Since the MGT IP is the primary interface, a static DNS registration is not required. Skipping..."
 pMGTisNotPrimary = "The MGT IP is NOT the primary interface. The primary IP will be registered automatically..."
 pRegisterDnsBUR = "Registering BUR DNS A and PTR records if BUR interface is configured..."
 pNotConfiguredBUR = "BUR interface is not configured. Skipping DNS A and PTR registrations..."
 pAddDevPreRoutes = "Adding DEV PRE routes..."
 pAddDevAppRoutes = "Adding DEV APP routes..."
 pAddDevDtaRoutes = "Adding DEV DATA routes..."
 pAddTstPreRoutes = "Adding TST PRE routes..."
 pAddTstAppRoutes = "Adding TST APP routes..."
 pAddTstDtaRoutes = "Adding TST DATA routes..."
 pAddPrdPreRoutes = "Adding PRD PRE routes..."
 pAddPrdAppRoutes = "Adding PRD APP routes..."
 pAddPrdDtaRoutes = "Adding PRD DATA routes..."
 pAddCntRoutes = "Adding CNT routes..."
 pAddHpcCderRoutes = "Adding HPC CDER routes..."
 pAddHpcCENTER2Routes = "Adding HPC CENTER2 routes..."
 pAddEntSvcsRoutes = "Adding ENT SVCS routes..."
 pAddEntFileRoutes = "Adding ENT FILE routes..."
 pAddEntVoipRoutes = "Adding ENT VOIP routes..."
 pAddEntVideoRoutes = "Adding ENT VIDEO routes..."
 pAddMgtRoutes = "Adding MGT routes..."
 pUnknownZone = "The ZONE cannot be determined..."
 pCheckForEMET = "Checking for EMET..."
 pEmetOK = "The required EMET version is already installed. Skipping..."
 pEmetNA = "The required version of EMET is not yet installed. Installing now..."
 pNetIQAgentNA = "NetIQ Agent is not installed. Installing now..."
 pNetIQAgentOK = "NetIQ Agent is already installed. Skipping..."
 pNetIQAMFWNA = "NetIQ Windows Module (AppManager For Windows [AMFW]) is not installed. Installing now..."
 pNetIQAMFWOK = "NetIQ Windows Module (AppManager For Windows [AMFW]) is already installed. Skipping..."
 pVSENA = "McAfee VirusScan Enterprise is not installed. Installing now..."
 pVSEOK = "McAfee VirusScan Enterprise is already installed. Skipping..."
 pDelAgentGUID = "Removing EPO AgentGUID if available..."
 pAgentGuidExists = "EPO AgentGUID exists. Removing..."
 pAgentGuidNA = "EPO AgentGUID does not exist. Skipping..."
 pCheck4MIR = "Checking for existing Mandiant Agent (MIR) installation..."
 pMirNA = "Mandiant (MIR) is not installed. Installation will not occur during execution of this script because the SCCM Team will remotely install updated versions of Mandiant..."
 pMirOK = "Mandiant Agent (MIR) is already installed. Skipping..." 
 pEpoNon<>DataCenter = "Installing non-<>DataCenter EPO version..."
 pEpo<>DataCenter = "Installing <>DataCenter EPO version..."
 pEpoNA = "EPO Agent is not installed. Installing..."
 pEpoOk = "EPO Agent is already installed. Skipping..."
 pSysDriveLabel = "SYSTEM"
 pAdToolInstalled = "AD tool has already been installed. Skipping..."
 pInstallAdPSTool = "RSAT-AD-PowerShell tool is available. Installing feature..."
 pCheck4ADTool = "Checking to see if the AD features tool has been installed..."
 pAddSerialVirtual = "Server is virtual. Adding virtual serial number file at C:\Software\VIRT_<SerialNumber>.ser..."
 pAddBarcodeVirtual = "Server is virtual. Adding virtual barcode file at C:\Software\VIRT_<Barcode>.ORG..."
 pAddSerialPhysical = "Server is virtual. Adding virtual serial number file at C:\Software\<SerialNumber>.ser..."
 pAddBarcodePhysical = "Server is virtual. Adding virtual barcode file at C:\Software\<Barcode>.ORG..."
 pLocalSWNA = "The path does not exist. Creating it now..."
 pAddSerialAndBarcode = "Adding serial and barcode files..."
 pNetIQAgentRef = "The NetIQ Agent installation instructions are available starting at step 23 at: http://ecmsweb.ORG.gov:8080/webtop/drl/objectId/090026f88043b4a8..."   
 pAddServerGrpToLocalAdmins = "Adding srvradmin-<HOSTNAME> group to local admins..."
 pRegisteringMGT = "Registering MGT interface A and PTR records for non-MGT zone server..."
 pEnablePSRem = "Enabling PowerShell Remoting if not already configured..."
 pSetTimeout = "Setting OS startup timeout value..."
 pEndOfScript = "End of Script!"
} #end $MsgsObj

# Create and populate prompts object with property-value pairs
# PROMPTS (PromptsObj)
$PromptsObj = [PSCustomObject]@{
 pVerifySummary = "Is this information correct? [YES/NO]"
 pAskToRestart = "Restart computer now ? [YES/NO]"
 pAskToOpenLog = "Would you like to open the deployment log now ? [YES/NO]"
} #end $PromptsObj

# Create and populate responses object with property-value pairs
# RESPONSES (ResponsesObj): Initialize all response variables with null value
$ResponsesObj = [PSCustomObject]@{
 pProceed = $null
 pReboot = $null
 pOpenLogNow = $null
} #end $ResponsesObj

# Create and populate versions object with property-value pairs
# VERSIONS (VersObj)
$VersObj = [PSCustomObject]@{
 pNBUClientVer = "7.5"
 pPSVer = $Host.Version.Major 
 pEmetRequired = "EMET 4.1"
} #end $VersObj

# Create and populate searches object with property-value pairs
# SEARCH-STRINGS (SearchesObj)
$SearchesObj = [PSCustomObject]@{
 pdnsRSAT="[X] DNS Server Tools  [RSAT-DNS-Server]"
 padtRSAT="[X] AD DS Snap-Ins and Command-Line Tools  [RSAT-ADDS-Tools]"
} #end $SearchesObj

# Create and populate networks object with property-value pairs
# Bit mask CIDR notation of "\23" is consistent for all possible subnets (Subnet Mask: 255.255.254.0)
# Networks (NetsObj)
$NetsObj = [PSCustomObject]@{
 pMgtNetwork = "10.177.80.0/23"
 pBurNetwork = "10.182.90.0/23"
} #end $NetsObj

$GWsObj = [PSCustomObject]@{
 pDevPreMgt01GW = "10.177.144.1"
 pDevPreBur01GW = "10.182.64.1"
 pDevAppMgt01GW = "10.177.146.1" 
 pDevAppMgt02GW = "10.177.212.1" 
 pDevAppBur01GW = "10.182.68.1" 
 pDevAppBur02GW = "10.182.116.1" 
 pDevDtaMgt01GW = "10.177.148.1" 
 pDevDtaBur01GW = "10.182.72.1"
 pTstPreMgt01GW = "10.183.144.1" 
 pTstPreBur01GW = "10.182.66.1"
 pTstAppMgt01GW = "10.183.146.1"
 pTstAppMgt02GW = "10.183.188.1"
 pTstAppBur01GW = "10.182.70.1"
 pTstAppBur02GW = "10.182.120.1"
 pTstDtaMgt01GW = "10.183.148.1"
 pTstDtaBur01GW = "10.182.74.1"
 pPrdPreMgt01GW = "10.177.150.1" 
 pPrdPreBur01GW = "10.182.76.1"
 pPrdAppMgt01GW = "10.177.152.1" 
 pPrdAppMgt02GW = "10.177.228.1"
 pPrdAppBur01GW = "10.182.80.1"
 pPrdAppBur02GW = "10.182.136.1"
 pPrdDtaMgt01GW = "10.177.154.1" 
 pPrdDtaBur01GW = "10.182.84.1"
 pCntMgt01GW = "10.183.150.1" 
 pCntBur01GW = "10.182.88.1"
 pHpcCderMgt01GW = "10.183.152.1" 
 pHpcCderBur01GW = "10.182.92.1"
 pHpcCENTER2Mgt01GW = "10.183.154.1"
 pHpcCENTER2Bur01GW = "10.182.94.1"
 pEntSvcMgt01GW = "10.177.156.1" 
 pEntSvcBur01GW = "10.182.156.1" 
 pEntFileMgt01GW = "10.177.158.1"
 pEntFileBur01GW = "10.182.158.1"
 pEntVoipMgt01GW = "10.177.160.1" 
 pEntVoipBur01GW = "10.182.160.1"
 pEntVideoMgt01GW = "10.177.162.1"
 pEntVideoBur01GW = "10.182.162.1"
 pMgtShaBur01GW = "10.182.106.1"
} #end $GWsObj

If ($IsCitrix -eq "TRUE") 
{
 # $IsCitrix enabled paths
 $DirsObj.pLogPath = $DirsObj.pctxLogPath
 $DirsObj.pSoftwarePath = $DirsObj.pctxSoftwarePath
 $DirsObj.pDeployPath = $DirsObj.pctxDeployPath
 $DirsObj.pPsToolsPath = $DirsObj.pctxPsToolsPath
} #end If $IsCitrix

# Convert string parameters to upper case. Dot-sourced to force script scope
. Convert-StringParamsToUpper 

# Populate Summary Display Object
# Add properties and values
 $SummObj = [PSCustomObject]@{
 HOSTNAME = $hostname
 OS = $OS
 RAM = $PhyMem
 LOCATION = $DataCenter
 ZONE = $Zone
 LAYER = $Layer
 CENTER = $Center
 APPLICATION = $Application
 APPLICATIONID = $AppID
 PRIMARYIP = $ProdIP
 MANAGEMENTIP = $MGTIP
 BURIP = $BURIP
 SERIAL = $Serial
 BARCODE = $Barcode
 VIRTUAL = $IsVMware
 CITRIX = $IsCitrix
 } #end $SummObj

#***********************
# MAIN	
#***********************

# PHASE 01: SETUP 
# If ($SummObj.ZONE -eq "MGT")
# {
#  $SummObj.MANAGEMENTIP = $SummObj.PRIMARYIP
# } #end If

# Set system drive label
Set-Volume -DriveLetter "C" -NewFileSystemLabel $MsgsObj.pSysDriveLabel

# Setup console environment
# Clear screen
Clear-Host 
# Set foreground color 
$host.ui.RawUI.ForegroundColor = $MsgsObj.pOriginalForeground

# Display header
$MsgsObj.pHdrTop | Tee-Object -FilePath $FilesObj.pLog 
ShowAndLog($MsgsObj.pHeader)
ShowAndLog($MsgsObj.pHdrLow)

# Display Summary
ShowAndLog($SummObj)
ShowAndLog($MsgsObj.pHdrLow)

# Verify parameter values#
Do {
$ResponsesObj.pProceed = read-host $PromptsObj.pVerifySummary
$ResponsesObj.pProceed = $ResponsesObj.pProceed.ToUpper()
}
Until ($ResponsesObj.pProceed -eq "Y" -OR $ResponsesObj.pProceed -eq "YES" -OR $ResponsesObj.pProceed -eq "N" -OR $ResponsesObj.pProceed -eq "NO")

# Record prompt and response in log
LogToFile($PromptsObj.pVerifySummary)
LogToFile($ResponsesObj.pProceed)

# Exit if user does not want to continue

if ($ResponsesObj.pProceed -eq "N" -OR $ResponsesObj.pProceed -eq "NO")
{
  ShowAndLog($MsgsObj.pUseDeploymentFE)
  PAUSE
  EXIT
 } #end if ne Y
else 
{
# Proceed to configuring server
ShowAndLog($MsgsObj.pHdrLow)
ShowAndLog("")
# PHASE 02: PRE-REQUISITES
 LogWithTime($MsgsObj.pCfgServer)

  # Check for PowerShell 4.0 version and if necessary install Windows Management Framework 4.0 components (WinRM, WMI and PowerShell 4.0)
 LogWithTime($MsgsObj.pCheckPSver)
 If ($VersObj.pPSver -ne 4) 
 # Install Windows Management Framework 4.0
 # Ref: Windows Update Standalone Installer (wusa.exe) http://support.microsoft.com/kb/934307
 # Ref: Installing Multiple MSUs using PowerShell: http://powershell.com/cs/forums/p/16375/36311.aspx
 {
  # Highlight output for emphasis
  $host.ui.RawUI.ForegroundColor = $MsgsObj.pEmphasisForeground
  LogWithTime($MsgsObj.pPSverNot4a)
  LogWithTime($MsgsObj.pPSverNot4b)
  LogWithTime($MsgsObj.pPSverNot4c)
  LogWithTime($MsgsObj.pPSverNot4d)
  # Reset output color to original
  $host.ui.RawUI.ForegroundColor = $MsgsObj.pOriginalForeground

  $WM4msu = Join-Path -Path $DirsObj.pWMF4Path -ChildPath $FilesObj.pWMF4File
  # Install WMF 4.0
  Start-Process $FilesObj.pWUSAPath $WM4msu -Wait
  # Restart server to immediately apply changes after reboot
  PAUSE
  Restart-Computer
 } #end If
 else 
 {
  # Windows Management Framework 4.0 has already been installed and Powershell Version 4.0 is available
  LogWithTime($MsgsObj.pPSverIs4)
 } #end else

# If the Remote Registry service is not running, start it and set the startup type to Auto if necessary.
$msgCheckRR = "Checking the Remote Registry service. If the Remote Registry service is not running, it will be changed to running and the startup type will be set to Auto if necessary..."
LogWithTime($msgCheckRR)
$SvcStatusRR = (Get-Service -Name RemoteRegistry -ErrorAction SilentlyContinue).Status 
$SvcStartupTypeRR = (Get-WmiObject -Query "Select StartMode From Win32_Service Where Name=RemoteRegistry" -ErrorAction SilentlyContinue).StartMode
If ($SvcStartupTypeRR -ne "Auto")
{ 
 # Set service startup type to Auto
 Set-Service -Name RemoteRegistry -StartupType Auto -ErrorAction SilentlyContinue
}
If ($SvcStatusRR -ne "Running")
{ 
 # Start Remote Registry Service
 Start-Service -Name RemoteRegistry -Force -ErrorAction SilentlyContinue
} #end If

# If the Windows Firewall service is running, stop it and set the startup type to disabled.
$msgCheckFW = "Checking the Windows Firewall service. If the Windows Firewall service is running, it will be stopped and the startup type will be set to Disabled..."
LogWithTime($msgCheckFW)
$SvcStatusFW = (Get-Service -Name MpsSvc -ErrorAction SilentlyContinue).Status 
$SvcStartupTypeFW = (Get-WmiObject -Query "Select StartMode From Win32_Service Where Name=MpsSvc" -ErrorAction SilentlyContinue).StartMode
If (($SvcStatusFW -eq "Running") -OR ($SvcStartupTypeFW -ne "Disabled"))
{ 
 Stop-Service -Name MpsSvc -Force -ErrorAction SilentlyContinue
 Set-Service -Name MpsSvc -StartupType Disabled -ErrorAction SilentlyContinue
} #end If

# If the Print Spooler service is running, stop it and set the startup type to disabled.
$msgCheckPS = "Checking the Print Spooler service. If the Print Spooler service is running, it will be stopped and the startup type will be set to Disabled..."
LogWithTime($msgCheckPS)
$SvcStatusPS = (Get-Service -Name Spooler).Status
$SvcStartupTypePS = (Get-WmiObject -Query "Select StartMode From Win32_Service Where Name=Spooler" -ErrorAction SilentlyContinue).StartMode
If (($SvcStatusPS -eq "Running") -OR ($SvcStartupTypePS -ne "Disabled"))
{ 
 Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
 Set-Service -Name Spooler -StartupType Disabled -ErrorAction SilentlyContinue
} #end If

# If the Windows Installer service startup type is not set to manual, set it to manual.
$msgCheckWI = "Checking the Windows Installer service. If the Windows Installer service is not set to Manual, it will now be set to Manual..."
LogWithTime($msgCheckWI)
$SvcStartupTypeWI = (Get-WmiObject -Query "Select StartMode From Win32_Service Where Name=msiserver" -ErrorAction SilentlyContinue).StartMode
If ($SvcStartupTypeWI -ne "Manual")
{
 Set-Service -Name msiserver -StartupType Manual -ErrorAction SilentlyContinue
} #end If

 # ADD DNS entries
 # Check to see if the DNS Server Tools feature is installed. If not, install it...
 LogWithTime($MsgsObj.pCheckForDnsTool)
 $DnsToolStatus = (Get-WindowsFeature -Name RSAT-DNS-Server).Installed
 If (!($DnsToolStatus))
 { 
  # Tool is available. Install feature.
  LogWithTime($MsgsObj.pInstallDnsTool)
  Install-WindowsFeature -Name RSAT-DNS-Server -IncludeManagementTools
 } #end if
 else 
 {
  LogWithTime($MsgsObj.pDnsToolInstalled)
  # Tool has already been installed. Skipping.
 } #end else

 # ADD Active Directory module feature
 # Check to see if the AD module feature is installed. If not, install it...
 LogWithTime($MsgsObj.pCheck4ADTool)
 $AdToolStatus = (Get-WindowsFeature -Name RSAT-AD-PowerShell).Installed
 If (!($AdToolStatus)) 
 { 
  # Tool is available. Install feature.
  LogWithTime($MsgsObj.pInstallAdPSTool)
  Install-WindowsFeature -Name RSAT-AD-PowerShell -IncludeManagementTools
 } #end if
 else 
 {
  LogWithTime($MsgsObj.pAdToolInstalled)
  # Tool has already been installed. Skipping.
 } #end else

 # Import AD module
 Import-Module -Name ActiveDirectory
 
 # Check to see if the DnsServer module is loaded. If not, load it...
 # http://blogs.technet.com/b/heyscriptingguy/archive/2010/07/11/hey-scripting-guy-weekend-scripter-checking-for-module-dependencies-in-windows-powershell.aspx
 LogWithTime($MsgsObj.pCheckAndLoadDnsMod)
 $ModuleName = "DnsServer"
 If (-Not(Get-Module -Name $ModuleName))
 { 
  # If module is available...
  if(Get-Module -ListAvailable | Where-Object { $_.name -eq $ModuleName }) 
  {
   # Then import module  
   LogWithTime($MsgsObj.pImportDnsSvrModule)
   Import-Module -Name $ModuleName 
  } #end if module available then import 
  else # Module is not availabe
  {
   LogWithTime($MsgsObj.pDnsModNA)
  } #end else
 } #end If module is available
 else # Module has already been loaded...
 {
  LogWithTime($MsgsObj.pDnsModLoaded)
 } #end else 

 # Updating help files for newly installed DNS features
 LogWithTime($MsgsObj.pUpdateHelp)
 Update-Help

 # Set OS Startup Timeout...
 LogWithTime($MsgsObj.pSetTimeout)
 Invoke-Command { bcdedit /timeout $tov }
 
 # Enable PowerShell Remoting if not already configured
 LogWithTime($MsgsObj.pEnablePSRem)
  Enable-PSRemoting -Force

 # Install SNMP Service from Server Manager Features if required
 $IsSnmpFeatureInstalled = Get-WindowsFeature -Name SNMP-Service
 # Verify Windows Services Are Enabled
 $msgSnmpFeatureOK = "The SNMP feature is already installed..."
 $msgSnmpServiceOK = "The SNMP service is already running..."
 $msgSnmpServiceNA = "The SNMP service is not started. Starting SNMP service now..."
  If ($IsSnmpFeatureInstalled.Installed -eq "True")
 {
  LogWithTime($msgSnmpFeatureOK)
  If ((Get-Service -Name SNMP).Status -eq "Running")
  {
   LogWithTime($msgSnmpServiceOK)
  } #end If
  else
  {
   LogWithTime($msgSnmpServiceNA)
   Start-Service -Name "SNMP"
  } #end else
 } #end If
 else
 {
  #Install/Enable SNMP-Service
  $msgInstallSNMP = "SNMP Service feature is not installed. Installing now..."
  LogWithTime($msgInstallSNMP)
  Get-WindowsFeature -name SNMP* | Add-WindowsFeature -IncludeManagementTools | Out-Null
 } #end else

 # PHASE 03: CONFIGURATION
  
 # MGT IP
 # If the MGT IP is the primary interface, skip creating static DNS A record for MGT Layer
 LogWithTime($MsgsObj.pChkNONpriIP)
 If ($SummObj.LAYER -eq "MGT")
 {
  # Since the MGT IP is the primary interface, a static DNS registration is not required. Skipping...
  LogWithTime($MsgsObj.pMGTisPrimary) 
 } #end if
 else
 {
  # The MGT IP is NOT the primary interface. The primary interface A and PTR records will be registered automatically...
  LogWithTime($MsgsObj.pMGTisNotPrimary)
  # Registering MGT interface A and PTR records for non-MGT zone server...
  LogWithTime($MsgsObj.pRegisteringMGT)
  $HostnameMGT = $SummObj.HOSTNAME + "-MGT"
  LogWithTime("Registering MGT interface name: " + $HostnameMGT)
  Add-DnsServerResourceRecordA -Name $HostnameMGT -ZoneName "ORG.gov" -IPv4Address $SummObj.MANAGEMENTIP -ComputerName $DnsSvr -CreatePtr -ErrorAction SilentlyContinue
 } #end else

 # BUR IP
 # Register BUR A and PTR records if available
 If (($SummObj.BURIP.Length) -gt 0)
 {
  # BUR available. Register in DNS...
  LogWithTime($MsgsObj.pRegisterDnsBUR)
  # Append -BUR to hostname for BUR interface
  $HostnameBUR = $SummObj.HOSTNAME + "-bur"
  $HostnameBUR = $HostnameBUR.ToLower()
  Add-DnsServerResourceRecordA -Name $HostnameBUR -ZoneName "ORG.gov" -IPv4Address $SummObj.BURIP -ComputerName $DnsSvr -CreatePtr -ErrorAction SilentlyContinue
 } #end if
 else
 {
  # BUR not available. Skip DNS registration...
  LogWithTime($MsgsObj.pNotConfiguredBUR)
 } #end else

 # CONFIGURE STATIC ROUTES
 Switch ($SummObj.ZONE)
 {
  # Add DEV ZONE routes
  
  "DEV" 
   {
    Switch ($SummObj.LAYER)
    {
     "PRE" 
     {# TASK-ITEM: 002 $MsgsObj.pAddDevPreRoutes = "Adding DEV PRE routes..."
      # Adding DEV PRE Routes...
      LogWithTime($MsgsObj.pAddDevPreRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pDevPreMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pDevPreBur01GW
     } #end PRE
     "APP" 
     {# TASK-ITEM: 003 $MsgsObj.pAddDevAppRoutes = "Adding DEV APP routes..."
      # Adding DEV APP routes...
      LogWithTime($MsgsObj.pAddDevAppRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pDevAppMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pDevAppMgt02GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pDevAppBur01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pDevAppBur02GW
     } #end APP
     "DATA" 
     {# TASK-ITEM: 004 $MsgsObj.pAddDevDtaRoutes = "Adding DEV DATA routes..."
      # Adding DEV DATA routes...
      LogWithTime($MsgsObj.pAddDevDtaRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pDevDtaMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pDevDtaBur01GW
     } #end DATA
    } #end Switch Layer
   } #end DEV

  # Add TST ZONE routes
  "TST" 
   {
    Switch ($SummObj.LAYER)
    {
     "PRE"
     {# TASK-ITEM: 005 $MsgsObj.pAddTstPreRoutes = "Adding TST PRE routes..."
      # Adding TST PRE routes...
      LogWithTime($MsgsObj.pAddTstPreRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pTstPreMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pTstPreBur01GW
     } #end PRE
     "APP"
     {# TASK-ITEM: 006 $MsgsObj.pAddTstAppRoutes = "Adding TST APP routes..."
      # Adding TST APP routes...
      LogWithTime($MsgsObj.pAddTstAppRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pTstAppMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pTstAppMgt02GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pTstAppBur01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pTstAppBur02GW
     } #end APP 
     "DATA"
     {# TASK-ITEM: 007 $MsgsObj.pAddTstDtaRoutes = "Adding TST DATA routes..."
      # Adding TST DATA routes...
      LogWithTime($MsgsObj.pAddTstDtaRoute)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pTstDtaMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pTstDtaBur01GW
     } #end DATA
    } #end Switch Layer
   } #end TST

  # Add PRD ZONE routes
  "PRD" 
   {
    Switch ($SummObj.LAYER)
    {
     "PRE"
     {# TASK-ITEM: 008 $MsgsObj.pAddPrdPreRoutes = "Adding PRD PRE routes..."
     # Adding PRD PRE routes...
     LogWtihTime($MsgsObj.pAddPrdPreRoutes)
     New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pPrdPreMgt01GW
     New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pPrdPreBur01GW
    } #end PRE
     "APP"
     {# TASK-ITEM: 009 $MsgsObj.pAddPrdAppRoutes = "Adding PRD APP routes..."
     # Adding PRD APP routes...
     LogWithTime($MsgsObj.pAddPrdAppRoutes)
     New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pPrdAppMgt01GW
     New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pPrdAppMgt02GW
     New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pPrdAppBur01GW
     New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pPrdAppBur02GW
    } #end APP
     "DATA"
     {# TASK-ITEM: 010 $MsgsObj.pAddPrdDtaRoutes = "Adding PRD DATA routes..."
     # Adding PRD DATA routes...
     LogWithTime($MsgsObj.pAddPrdDtaRoutes)
     New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pPrdDtaMgt01GW 
     New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pPrdDtaBur01GW
    } #end DATA
    } #end Switch Layer
   } #end PRD

  "CNT" 
   {# TASK-ITEM: 011 $MsgsObj.pAddCntRoutes = "Adding CNT routes..."
    # Adding CNT routes...
    LogWithTime($MsgsObj.pAddCntRoutes)
    New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pCntMgt01GW
    New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pCntBur01GW
   } #end CNT

  # Add HPC ZONE routes
  "HPC" 
   {
    Switch ($SummObj.LAYER)
    {
     "CDER"
     {# TASK-ITEM: 012 $MsgsObj.pAddHpcCderRoutes = "Adding HPC CDER routes..."
      # Adding HPC CDER routes...
      LogWithTime($MsgsObj.pAddHpcCderRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pHpcCderMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pHpcCderBur01GW
     } #end CDER
     "CENTER2"
     {# TASK-ITEM: 013 $MsgsObj.pAddHpcCENTER2Routes = "Adding HPC CENTER2 routes..."
      # Adding HPC CENTER2 routes...
      LogWithTime($MsgsObj.pAddHpcCENTER2Routes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pHpcCENTER2Mgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pHpcCENTER2Bur01GW 
     } #end CENTER2
    } #end Switch Layer
   } #end HPC

   # Add ENT ZONE routes
  "ENT" 
   {
    Switch ($SummObj.LAYER)
    {
     "SVCS"
     {# TASK-ITEM: 014 $MsgsObj.pAddEntSvcsRoutes = "Adding ENT SVCS routes..."
      # Adding ENT SVCS routes...
      LogWithTime($MsgsObj.pAddEntSvcsRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pEntSvcMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pEntSvcBur01GW
     } #end SVCS
     "FILE"   
     {# TASK-ITEM: 015 $MsgsObj.pAddEntFileRoutes = "Adding ENT FILE routes..."
      # Adding  ENT File routes...
      LogWithTime($MsgsObj.pAddEntFileRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pEntFileMgt01GW
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pEntFileBur01GW
     } #end FILE
     "VOIP"
     {# TASK-ITEM: 016 $MsgsObj.pAddEntVoipRoutes = "Adding ENT VOIP routes..."
      # Adding  ENT VOIP routes...
      LogWithTime($MsgsObj.pAddEntVoipRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pEntVoipMgt01GW 
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pEntVoipBur01GW
     } #end VOIP
     "VIDEO"
     {# TASK-ITEM: 017 $MsgsObj.pAddEntVideoRoutes = "Adding ENT VIDEO routes..."
      # Adding  ENT VIDEO routes...
      LogWithTime($MsgsObj.pAddEntVideoRoutes)
      New-NetRoute –DestinationPrefix $NetsObj.pMgtNetwork -InterfaceAlias "MGT" -NextHop $GWsObj.pEntVideoMgt01GW 
      New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pEntVideoBur01GW
     } #end VOIP
    } #end Switch Layer
   } #end ENT

  # Add MGT ZONE routes
   "MGT" 
   {
    # Adding MGT routes...
    LogWithTime($MsgsObj.pAddMgtRoutes)
    # TASK-ITEM-BUG: New-NetRoute : Instance MSFT_NetRoute already exists. (ErrorAction is continue by defualt)
    New-NetRoute –DestinationPrefix $NetsObj.pBurNetwork -InterfaceAlias "BUR" -NextHop $GWsObj.pMgtShaBur01GW -ErrorAction SilentlyContinue
   } #end MGT
  
  # Account for unconfigured ZONE
  Default
   {
    # Zone is undetermined...
    # 
    LogWithTime($MsgsObj.pUnknownZone)
   } #end Default

 } #end Switch ZONE

 # Update computer object description
 # Check description of computer object and if necessary, modify description field
 LogWithTime($MsgsObj.pCheckSvrDesc)
 $DesiredDesc = $SummObj.CENTER + " | " + $SummObj.APPLICATION + " | " + $SummObj.APPLICATIONID + " | " + $SummObj.ZONE + " | " + $SummObj.LAYER
 [string]$strDesiredDesc = $DesiredDesc
 $CurrentDesc = Get-ADComputer $SummObj.HOSTNAME -Properties description | Select-Object -Property description
 # TASK-ITEM-BUG: Method invocation failed because [Selected.Microsoft.ActiveDirectory.Management.ADComputer] does not contain a method named 'Contains'. Remove "" from $DesireDesc
 [string]$strCurrDesc = $CurrentDesc
 $IsPartOf =  $strCurrDesc.Contains($strDesiredDesc)
 # Set description if it has not already been set
 If (-Not($IsPartOf)) 
 { 
  LogWithTime($MsgsObj.pApplySvrDesc)
  Set-ADComputer $SummObj.HOSTNAME -Description $DesiredDesc 
 }
 else
 {
  # Description was already set [properly]
  LogWithTime($MsgsObj.pSvrDescAlreadySet)
 } #end If

 # Add Server Administrators Group (srvradmin-<hostname>) to AD if required
 LogWithTime($MsgsObj.pCheckForSvrAdminGrp)
 $TargetSvrAdmGrp = "srvradmin-" + $SummObj.HOSTNAME
 $SearchForGrp = (Get-ADGroup $TargetSvrAdmGrp).Name
 If ($TargetSvrAdmGrp -ne $SearchForGrp) 
 {
  # Server admin group not set. Adding...
  LogWithTime($MsgsObj.pAddADGroup)
  New-ADGroup -Name $TargetSvrAdmGrp -SamAccountName $TargetSvrAdmGrp -GroupCategory Security -GroupScope Global -Path $OUPathsObj.pSvrAdmGrpOU -Description $MsgsObj.pSvrGrpDesc 
 }
 else
 {
  # Server admin group already exist
  LogWithTime($MsgsObj.pADGroupAlreadyExist)
 } #end If
 
 # Adding server to local administrators group
 LogWithTime($MsgsObj.pAddServerGrpToLocalAdmins)
 $SrvAdminGrp = "srvradmin-" + $SummObj.HOSTNAME
 $DomainObj = "ORG"
 $Computer = $SummObj.HOSTNAME
 $LocalAdmGroup = "Administrators"

 # REFS: http://techibee.com; https://4sysops.com/archives/add-a-domain-user-or-group-to-local-administrators-with-powershell/
 # Author: Sitaram Pamarthi
 # Bind to ADSI provider for local administrators group
 $GroupObj = [ADSI]"WinNT://$($Computer)/$($LocalAdmGroup)"
 # Add domain based group to local administrators group
 $GroupObj.Add("WinNT://$DomainObj/$SrvAdminGrp")
 # Apply change
 $GroupObj.SetInfo()
  
# VIRTUAL SN AND BARCODE
# Create local SW directory if it does not exist
 If (!(Test-Path -Path $DirsObj.pLocalSW))
 {
  # The path C:\Software does not exist
  LogWithTime($MsgsObj.pLocalSWNA)
  New-Item -Path $DirsObj.pLocalSW -ItemType Directory
 } #end If

# Adding serial and barcode files to C:\Software\
LogWithTime($MsgsObj.pAddSerialAndBarcode)
If ($SummObj.VIRTUAL -eq "TRUE")
{
 If (!(Test-Path -Path "$($DirsObj.pLocalSW)\VIRT_$($SummObj.HOSTNAME).ser" -PathType Leaf))
 {
  # Server is virtual. Adding virtual serial number file at C:\Software\VIRT_<SerialNumber>.ser
  LogWithTime($MsgsObj.pAddSerialVirtual)
  New-Item -ItemType file -Path "$($DirsObj.pLocalSW)\VIRT_$($SummObj.HOSTNAME).ser"
 } #end If

 If (!(Test-Path -Path "$($DirsObj.pLocalSW)\VIRT_$($SummObj.HOSTNAME).ORG" -PathType Leaf))
 {
  LogWithTime($MsgsObj.pAddBarcodeVirtual)
  New-Item -ItemType file -Path "$($DirsObj.pLocalSW)\VIRT_$($SummObj.HOSTNAME).ORG"
 } #end If

} #end If
else
{ 
 # PHYSICAL SN AND BARCODE
 # Server is physical. Adding physical serial number file at C:\Software\<SerialNumber>.ser
 If (!(Test-Path -Path "$($DirsObj.pLocalSW)\$($SummObj.SERIAL).ser" -PathType Leaf))
 { 
  # Serial file does not already exist
  LogWithTime($MsgsObj.pAddSerialPhysical)
  New-Item -ItemType file -Path "$($DirsObj.pLocalSW)\$($SummObj.SERIAL).ser"
 } #end If

 If (!(Test-Path -Path "$($DirsObj.pLocalSW)\$($SummObj.BARCODE).ORG" -PathType Leaf))
 {
  # Barcode file does not already exist
  LogWithTime($MsgsObj.pAddBarcodePhysical)
  New-Item -ItemType file -Path "$($DirsObj.pLocalSW)\$($SummObj.BARCODE).ORG"
 } #end If

} #end else 

# PHASE 04: APPLICATIONS 

# Check for EMET 
LogWithTime($MsgsObj.pCheckForEMET)

$EmetInstalled = "NO"
Get-ChildItem $DirsObj.pPrgmFilesX86 | ForEach-Object -Process {
 # EMET 4.1 is installed
 If($_.Name -eq $VersObj.pEmetRequired) 
 { 
  LogWithTime($MsgsObj.pEmetOK) 
  $EmetInstalled = "YES"
 } #end If
} #end ForEach-Object

If ($EmetInstalled -eq "NO")
# EMET Required version is NOT installed. Installing...
{
 LogWithTime($MsgsObj.pEmetNA)
 # TASK-ITEM-BUG: Join-Path : Cannot bind argument to parameter 'Path' because it is null; fix pending, assigned directory to pEmetDir property
 $EmetInstallPath = Join-Path -Path $DirsObj.pEmetDir -ChildPath $FilesObj.pEmetFile
 # TASK-ITEM-BUG: Start-Process : Cannot validate argument on parameter 'FilePath'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again; fix pending, see previous BUG
 Start-Process -FilePath $EmetInstallPath -ArgumentList $MsiArgs -Wait
} #end If

# Check/Install Password Complexity: Only domain password complexity policy applies and overwrites all other GPOs for account settings, including the local password complexity policy
# If (Not((Get-ADDefaultDomainPasswordPolicy -Current LocalComputer).ComplexityEnabled))
# {
   # Local Password Complexity is not set
# } #end If

# CHECK FOR NetIQ

# Check for NetIQ Agent
If (Test-Path -Path $RegPathsObj.pNetIQAgent -PathType Container)
{
 # NetIQ is installed. Get Agent info
 $NetIQAgentInstalled = (Get-ItemProperty -Path $RegPathsObj.pNetIQAgent).$RegKeysObj.pName 
 If ($RegValsObj.pNetIQAgent -eq $NetIQAgentInstalled)
 {
  # The correct NetIQ Agent is installed.
  # NetIQ Agent is already installed. Skipping...
  LogWithTime($MsgsObj.pNetIQAgentOK)
 } #end If
} #end If
else
{
 # NetIQ Agent is not installed. Installing...
 LogWithTime($MsgsObj.pNetIQAgentNA)
 LogWithTime($MsgsObj.pNetIQAgentRef)
 Start-Process -FilePath $FilesObj.pSrcNetIQAgentMSI -Wait
} #end else

# Check for NetIQ Module (AMFW - AppManager For Windows)
If (Test-Path -Path $RegPathsObj.pNetIQAMFW -PathType Container)
{
  # NetIQ Windows Module (AppManager For Windows [AMFW]) is installed. Skipping...
  LogWithTime($MsgsObj.pNetIQAMFWOK)
 } #end If
#end If
else
{
 # NetIQ Windows Module (AppManager For Windows [AMFW]) is not installed. Installing...
 LogWithTime($MsgsObj.pNetIQAMFWNA)
 Start-Process -FilePath $FilesObj.pSrcNetIQWinOSMSI -ArgumentList $MsiArgs -Wait
} #end else

# Check for McAfee (2012 version)
If (Test-Path -Path $RegPathsObj.pAvEngine -PathType Container)
{ 
 $VirusScanInstalled = (Get-ItemProperty -Path $RegPathsObj.pAvEngine).$RegKeysObj.pVSE
 If ($VirusScanInstalled -eq $RegValsObj.pVseCoreRef)
 { 
  # McAfee VirusScan Enterprise is already installed. Skipping...
  LogWithTime($MsgsObj.pVSEOK)
 } #end If
} #end If
else
{
 # McAfee VirusScan Enterprise is not installed. Installing now...
 LogWithTime($MsgsObj.pVSENA)
 # Install VirusScan Engine
 Start-Process -Path $FilesObj.pRemVse -ArgumentList -$MsiArgs -Wait
 # Install Patch
 Start-Process -Path $FilesObj.pRemVsePatch -ArgumentList -$MsiArgs -Wait
 # Install HotFix
 Start-Process -Path $FilesObj.pRemVseHF -ArgumentList -$MsiArgs -Wait
} #end else

# Check for McAfee EPO Agent
If (Test-Path -Path $RegPathsObj.pAvAgent)
{ 
 # EPO Agent is installed
 LogWithTime($MsgsObj.pEpoOK)

# Removing ePO AgentGUID if available...
LogWithTime($MsgsObj.pDelAgentGUID)
If (Test-Path -Path $RegPathsObj.pAvAgent)
{
 LogWithTime($MsgsObj.pAgentGuidExists)
 [string]$AGUID = (Get-ItemProperty -Path $RegPathsObj.pAvAgent).AgentGUID
 $msgCurrentAgentGUID = "Current AgentGUID is: " + $AGUID
 LogWithTime($msgCurrentAgentGUID)
 LogWithTime("Removing current AgentGUID registry key from original server template")
 Remove-ItemProperty -Path $RegPathsObj.pAvAgent -Name AgentGUID
 LogWithTime("Restarting McAfeeFramework service to generate new AgentGUID key and value for new deployed server")
 Restart-Service -Name McAfeeFramework
} #end If
else
{
 LogWithTime($MsgsObj.pAgentGuidNA)
} #end else

} #end If
else
{
 # EPO Agent has not been installed
 LogWithTime($MsgsObj.pEpoNA)
 If ($SummObj.LOCATION -eq "<>DataCenter")
 {
  # Installing <>DataCenter EPO version
  LogWithTime($MsgsObj.pEpo<>DataCenter)
  Start-Process -Path $FilesObj.pEpoAgentRemFile<>DataCenter -ArgumentList $MsiArgs -Wait 
 } #end If <>DataCenter
 else
 {
  # Installing non-<>DataCenter EPO version
  LogWithTime($MsgsObj.pEpoNon<>DataCenter)
  Start-Process -Path $FilesObj.pEpoAgentRemFileNot<>DataCenter -ArgumentList $MsiArgs -Wait
 } #end else non-<>DataCenter

} #end else EPO Agent is installed

# Check for Mandiant
LogWithTime($MsgsObj.pCheck4MIR)
If (Get-Service IntelligentResponseAgent)
{
 # Mandiant Agent is already installed. Skipping
 LogWithTime($MsgsObj.pMirOK)
} #end If
else
{
 # Mandiant is not installed. Installation will not occur during execution of this script because the SCCM Team will remotely install updated versions of Mandiant...
 LogWithTime($MsgsObj.pMirNA)
 # Start-Process -FilePath $FilesObj.pMIRRemotePath -ArgumentList $MsiArgs -Wait
} #end else

} #end If

#***********************
# FOOTER		
#***********************
# Remove the DNS server tools to remove attack surface of currently configured server
LogWithTime($MsgsObj.pRemoveDnsTool)
UnInstall-WindowsFeature -Name RSAT-DNS-Server -IncludeManagementTools

LogWithTime($MsgsObj.pRemoveADTools)
# Remove the AD server tools to remove attack surface of currently configured server
UnInstall-WindowsFeature -Name RSAT-AD-PowerShell -IncludeManagementTools

# Prompt to open log
Do 
{
 $ResponsesObj.pOpenLogNow = read-host $PromptsObj.pAskToOpenLog
 $ResponsesObj.pOpenLogNow = $ResponsesObj.pOpenLogNow.ToUpper()
}
Until ($ResponsesObj.pOpenLogNow -eq "Y" -OR $ResponsesObj.pOpenLogNow -eq "YES" -OR $ResponsesObj.pOpenLogNow -eq "N" -OR $ResponsesObj.pOpenLogNow -eq "NO")

# Exit if user does not want to continue
if ($ResponsesObj.pOpenLogNow -eq "Y" -OR $ResponsesObj.pOpenLogNow -eq "YES") 
{
 Start-Process notepad.exe $FilesObj.pLog
} #end if

# Prompt for reboot
Do
{
$ResponsesObj.pReboot = read-host $PromptsObj.pAskToRestart
$ResponsesObj.pReboot = $ResponsesObj.pReboot.ToUpper()
}
Until ($ResponsesObj.pReboot -eq "Y" -OR $ResponsesObj.pReboot -eq "YES" -OR $ResponsesObj.pReboot -eq "N" -OR $ResponsesObj.pReboot -eq "NO")

# Record prompt and response in log
LogToFile($PromptsObj.pAskToRestart)
LogToFile($ResponsesObj.pReboot)

# Exit if user does not want to reboot
if ($ResponsesObj.pReboot -eq "Y" -OR $ResponsesObj.pReboot -eq "YES") 
{
 Restart-Computer
} #end if
else
{
 # End of script
 LogWithTime($MsgsObj.pEndOfScript)
} #end else

PAUSE
Exit-PSSession