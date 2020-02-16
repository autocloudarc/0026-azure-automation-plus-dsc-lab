<###########################################################################
# 																	
# Author       : Bhavik Solanki										
# Date         : 23th March 2012									
# Version      : 1.0												
# Desctiption  : This utility will help to retrieve SQL Server information.
#																	
###########################################################################>

param(
	[string]$InputFile,
	[string]$OutputFile
)

$ServerListFile = $InputFile
$OutputFile = $OutputFile

$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue

[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
$Result = @()
Foreach($SQLServer in $ServerList)
{
	$SQLServerInfo = new-object “Microsoft.SqlServer.Management.Smo.Server” $SQLServer 
	$Result += $SQLServerInfo | Select Name, Edition,ProductLevel, Version, ServerType, Platform, IsClustered, PhysicalMemory, Processors
}

if($Result -ne $null)
{
	$HTML = '<style type="text/css">
	#Header{font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;width:100%;border-collapse:collapse;}
	#Header td, #Header th {font-size:14px;border:1px solid #98bf21;padding:3px 7px 2px 7px;}
	#Header th {font-size:14px;text-align:left;padding-top:5px;padding-bottom:4px;background-color:#A7C942;color:#fff;}
	#Header tr.alt td {color:#000;background-color:#EAF2D3;}
	</Style>'

    $HTML += "<HTML><BODY><Table border=1 cellpadding=0 cellspacing=0 width=100% id=Header>
		<TR>
			<TH><B>Server Name</B></TH>
			<TH><B>Edition</B></TD>
			<TH><B>ProductLevel</B></TH>
			<TH><B>Version</B></TH>
			<TH><B>ServerType</B></TH>
			<TH><B>Platform</B></TH>
			<TH><B>IsClustered</B></TH>
			<TH><B>PhysicalMemory (MB)</B></TH>
			<TH><B>Logical Processors</B></TH>
		</TR>"
    Foreach($Entry in $Result)
    {
        $HTML += "<TR>
						<TD>$($Entry.Name)</TD>
						<TD>$($Entry.Edition)</TD>
						<TD align=center>$($Entry.ProductLevel)</TD>
						<TD>$($Entry.Version)</TD>
						<TD>$($Entry.ServerType)</TD>
						<TD>$($Entry.Platform)</TD>
						<TD align=center>$($Entry.IsClustered)</TD>
						<TD align=center>$($Entry.PhysicalMemory)</TD>
						<TD align=center>$($Entry.Processors)</TD>
					</TR>"
    }
    $HTML += "</Table></BODY></HTML>"

	$HTML | Out-File $OutputFile
}