function script:OutputProjects([Xml]$downloaded)
{
    foreach ($project in $downloaded.Projects.Project | sort name)
    {
        $lastBuildStatus = $project.lastBuildStatus
        $activity = $project.activity
        $projectname = $project.name
                    
        if($lastBuildStatus.StartsWith("Failure") -or $lastBuildStatus.StartsWith("Exception"))
        {
            if($projectName.Contains("Selenium"))
            {
                continue
            }
            if($projectname.Contains("Cas"))
            {
                write-host "projectname: $projectname :$lastBuildStatus" -foregroundcolor red -backgroundcolor black
            }
        }
        
        if($activity.StartsWith("Building"))
        {
            if($projectname.Contains("Cas"))
            {
                write-host "projectname: $projectname :$activity" -foregroundcolor yellow -backgroundcolor black
            }
        }
    }

}
function script:RetriveBuilds([String] $serverName)
{
    write-host "checking server " + $serverName
    $downloaded = ([Xml](New-Object Net.WebClient).DownloadString("http://" + $serverName +"/ccnet/xmlstatusreport.aspx")) 
    OutputProjects $downloaded
}

cls
#RetriveBuilds "Dba-Build64-01" 
#RetriveBuilds "Dba-Build64-02" 
RetriveBuilds "build-server64" 

