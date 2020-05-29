Configuration webroleremove {

    $features = @(
        @{Name = "Web-Server"; Ensure = "Absent"},
        @{Name = "Web-WebServer"; Ensure = "Absent"},
        @{Name = "Web-Common-http"; Ensure = "Absent"},
        @{Name = "Web-Default-Doc"; Ensure = "Absent"},
        @{Name = "Web-Dir-Browsing"; Ensure = "Absent"},
        @{Name = "Web-Http-Errors"; Ensure = "Absent"},
        @{Name = "Web-Static-Content"; Ensure = "Absent"},
        @{Name = "Web-Health"; Ensure = "Absent"},
        @{Name = "Web-Http-Logging"; Ensure = "Absent"},
        @{Name = "Web-Performance"; Ensure = "Absent"},
        @{Name = "Web-Stat-Compression"; Ensure = "Absent"},
        @{Name = "Web-Dyn-Compression"; Ensure = "Absent"},
        @{Name = "Web-Security"; Ensure = "Absent"},
        @{Name = "Web-Filtering"; Ensure = "Absent"},
        @{Name = "Web-Basic-Auth"; Ensure = "Absent"},
        @{Name = "Web-Windows-Auth"; Ensure = "Absent"},
        @{Name = "Web-App-Dev"; Ensure = "Absent"},
        @{Name = "Web-Net-Ext45"; Ensure = "Absent"},
        @{Name = "Web-Asp-Net45"; Ensure = "Absent"},
        @{Name = "Web-ISAPI-Ext"; Ensure = "Absent"},
        @{Name = "Web-ISAPI-Filter"; Ensure = "Absent"},
        @{Name = "Web-Ftp-Server"; Ensure = "Absent"},
        @{Name = "Web-Mgmt-Tools"; Ensure = "Absent"}
       )

    node localhost {

        foreach ($feature in $features){
            WindowsFeature ($feature.Name) {
                Name = $feature.Name
                Ensure = $feature.Ensure
            }
        }
    }
}