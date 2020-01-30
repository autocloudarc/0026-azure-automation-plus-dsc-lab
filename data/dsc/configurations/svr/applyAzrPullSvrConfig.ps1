Configuration applyAzrPullSvrConfig
{
    param (
        [string]$targetNode = 'localhost',
        [string]$role = 'svr',
        [string]$dataDiskNumber = '2',
        [string]$dataDiskDriveLetter = 'E',
        [string]$FSFormat = 'NTFS',
        [string]$FSLabel = 'DATA',
        [string]$Ensure = 'Present'
    ) # end param
    
    # Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xStorage
	Import-DscResource -ModuleName xPendingReboot
	# TASK-ITEM: Recommend using a designatd Server Administrator service account, not a domain adminstrator one for building member servers.
	# [pscredential]$domainAdminCred = Get-AutomationPSCredential 'domainAdminCred'

	Node $targetNode
	{
		<#
		svr.0001	DriveLetter	C|D|E	string		
		svr.0002	DriveLetter	C|D|E	string					
		svr.0003	DriveLetter	C|D|E	string					
		svr.0003	DriveLabel	WINDOWS|DATA	string				
		svr.0004	DriveLabel	WINDOWS|DATA	string					
		svr.0005	RDP	Enabled | Disabled	boolean	NOTES: Recommend Azure Bastion for Azure VMs. Require use of specific security layer for RDP. Allow users to connect remotely by using RDS.
		svr.0006	Firewall Service Status	Running | Stopped	string	NOTES: Current implemented via GPO
		svr.0007	Firewall Startup	Auto | Disabled | Manual	string				
		svr.0008	Firewall Profile State	Off (domain|private|public)	string				
		svr.0009	Time Zone	EST | (Hong Kong)	string	NOTES: Varies by location
		svr.0010	Backup VLAN NIC	Configured | Not-Configured	boolean	NOTES: Ensure only 1 NIC interface exists; ethernet | ethernet2 | lan connection (CGI); IBM?
		svr.0011	NIC Speed	1GB | 10 GB	string	NOTES: Check to ensure 1gb or 10gb
		svr.0012	NIC Teaming 	Configured | Not-Configured	boolean				
		svr.0013	DNS Settings	NOTES: More details required: DNS server search list; DNS Suffix list (GPO); Primary DNS Server is in same site as servers. Azure VNETS/SUBNETS ?
		svr.0014	WINS Settings	NOTES: More details required
		svr.0015	Domain Membership	Correct | Incorrect	boolean				
		svr.0016	Verify Description In AD	Present | Absent	boolean		
		svr.0018	Symantec Version ##.##	Present | Absent	boolean	NOTES: For Azure VMs, can antivirus extensions be configured automatically?
		svr.0019	Symantec NTP Absent	Present | Absent	boolean	NOTES: Remove if present
		svr.0020	Server in Master Inventory?	True | False	boolean	NOTES: Add if not-included
		svr.0021	Server has CI defined in Snow?	True | False	boolean	NOTES: Add CI in snow. What is the criteria to get CI defined in Snow? Done by CGI
		svr.0022	Request-CIUpdate	True | False	boolean	NOTES: Request update. What are the pre-requisites to request update?
		svr.0023	VMICTimeProvider\Enabled	0 | 1	int	NOTES: HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider\Enabled
		svr.0024	IPv6toIPv4 Reg Entries.REG	TBD	string[]	NOTES: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\ DisabledComponents
		svr.0025	Enable TLS 1.0		string				
		svr.0026	Enable TLS 1.1		string			
		svr.0027	Enable TLS 1.2?		string							
		svr.0028	VAST Registry setting	Present | Absent	boolean	NOTES: Apply and Monitor Only
		#>

		# Sample setting for item svr.0023
		Registry VMICTimeProvider
		{
			Ensure = $Ensure
			Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider'
			ValueName = 'Enabled'
			ValueData = '0'
			ValueType = 'Dword'
		} # end resource

		xDisk ConfigureDataDisk
		{
			DiskId = $dataDiskNumber
			DriveLetter = $dataDiskDriveLetter
            FSFormat = $FSFormat
            FSLabel = $FSLabel
		} # end resource
	} # end node
} # end configuration