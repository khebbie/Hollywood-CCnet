Add-Type –assemblyName PresentationFramework
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName WindowsBase

function CreateLabel($title, $color)
{
    $label = New-Object Windows.Controls.Label 
    $label.Content = $title
    $label.Background =$color
    $label
}

function CreateWindow($children)
{
    $window = New-Object Windows.Window 
    $window.Title = "ccnet"
	
    $stackPanel = New-Object Windows.Controls.StackPanel 
    $stackPanel.Orientation="Vertical" 
	
	
    foreach ($child in $children) 
    { 
		$child.FontSize = 17
        $frame = New-Object Windows.Controls.Frame 
        $frame.Content = $child
        $frame.BorderBrush = "Black"
        
        $null = $stackPanel.Children.Add($frame) 
        #$null = $stackPanel.Children.Add($child) 
        
    } 
    
    $eventHandler = [Windows.Input.KeyEventHandler]{$this.Close()} 
    $window.Add_KeyUp($eventHandler) 
    
    $window.Content = $stackPanel
    $window.SizeToContent = "WidthAndHeight" 
    $null = $window.ShowDialog()
}


function script:OutputProjects([Xml]$downloaded, $children)
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
                $children += CreateLabel "$projectname LastBuildStatus: $lastBuildStatus" "Red"
                #write-host "projectname: $projectname :$lastBuildStatus" -foregroundcolor red -backgroundcolor black
            }
        }
        
        if($activity.StartsWith("Building"))
        {
            if($projectname.Contains("Cas"))
            {
            $children += CreateLabel "$projectname LastBuildStatus: :$lastBuildStatus" "Yellow"
                #write-host "projectname: $projectname :$activity" -foregroundcolor yellow -backgroundcolor black
            }
        }
    }
    $children
}
function script:RetriveBuilds([String] $serverName, $children)
{
    write-host "checking server " + $serverName
    $downloaded = ([Xml](New-Object Net.WebClient).DownloadString("http://" + $serverName +"/ccnet/xmlstatusreport.aspx")) 
    OutputProjects $downloaded $children
}

cls
$buildServer = "build-server64"

$children = @() 
$children += CreateLabel "Checking BuildServer: $buildServer for last build" "White"
$children = RetriveBuilds "build-server64" $children

CreateWindow $children