<#region HELP
.SYNOPSIS 
Set the user's favorite NHL team

.DESCRIPTION
This cmdlet allows the user to set their favorite NHL team.  This team will be used in supported cmdlets
by default if a TeamName or TeamID parameter are ommitted.

.PARAMETER TeamName
The NHL team name to set as favorite.  The team name is an NHLTeam enum.

.PARAMETER Save
Use this parameter to save your favorite team and have it persist throughout sessions

.EXAMPLE
Set-NHLFavoriteTeam -TeamName PhiladelphiaFlyers

This example will set the user's favorite NHL Team to be the Philadelphia Flyers.

.EXAMPLE
Set-NHLFavoriteTeam -TeamName PhiladelphiaFlyers -Save

This example will set the user's favorite NHL Team to be the Philadelphia Flyers.  This setting will be saved and persist across sessions

#>

function Set-NHLFavoriteTeam {
    [CmdletBinding()]
    param (
    # Parameter help description
    [Parameter(Mandatory=$true, Position=0)]
    [NHLTeams]
    $TeamName,
    [Parameter()]
    [switch]
    $Save
    )

    process {      
        # Generate SavePath
        [string]$SavePath = (Join-Path (Split-Path -Path $PSScriptRoot -Parent) "settings.xml")

        # update PSNHL_SETTINGS in memory for just this session
        $Global:PSNHL_Settings.settings.data.favoriteTeamName = $TeamName.ToString()
        $Global:PSNHL_Settings.settings.data.favoriteTeamID = (Get-NHLTeamID -TeamName $TeamName).ToString()

        # user wants to persist settings
        if ($Save)
        {
            try 
            {
                $Global:PSNHL_Settings.Save($SavePath)
            }
            catch
            {
                Write-Error "Error saving favorite teams settings to disk at path: $SavePath Your favorite team settings will still persist for this session."
            }
        }
    }
}
