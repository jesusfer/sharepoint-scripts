Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

$usageConnectionString = (Get-SPUsageApplication).UsageDatabase.DatabaseConnectionString
$cli = new-object System.Data.SqlClient.SqlConnection
$cli.ConnectionString = $usageConnectionString
$cli.Open()

Get-SPSite -Limit All | Select-Object `
    @{Expression={$_.Id};Name="SiteId"}`
    ,@{Expression={$_.ContentDatabase.Name};Name="ContentDatabase"}`
    ,@{Expression={$_.RootWeb.Url};Name="Url"}`
    ,@{Expression={"{0:N0}" -f ($_.Usage.Storage/1MB)};Name="SiteSizeMB"}`
    ,@{Expression={(Get-Date).ToUniversalTime()};Name="DateTime"} | Foreach-Object {
        $sql = "INSERT INTO custom.SiteSize (SiteId, ContentDatabase, Url, SiteSizeMB, DateTime) VALUES ('$($_.SiteId)', '$($_.ContentDatabase)', '$($_.Url)', $($_.SiteSizeMB), '$($_.DateTime)')"
        $cmd = new-object System.Data.SqlClient.SqlCommand
        $cmd.CommandText = $sql
        $cmd.Connection = $cli
        $cmd.ExecuteScalar()
    }

Get-SPDatabase | Where-Object { $_.Type -eq "Content Database" } | Select-Object Name,CurrentSiteCount `
    ,@{Expression={$_.Id};Name="DatabaseId"}`
    ,@{Expression={"{0:N0}" -f ($_.DiskSizeRequired/1MB)};Name="DiskSizeRequiredMB"}`
    ,@{Expression={(Get-Date).ToUniversalTime()};Name="DateTime"} | Foreach-Object {
        $sql = "INSERT INTO custom.ContentDatabaseSize (DatabaseId, Name, SiteCount, DiskSizeRequired, DateTime) VALUES ('$($_.DatabaseId)', '$($_.Name)', $($_.CurrentSiteCount), $($_.DiskSizeRequiredMB), '$($_.DateTime)')"
        $cmd.CommandText = $sql
        $cmd.Connection = $cli
        $cmd.ExecuteScalar()
    }

$cli.Close()
