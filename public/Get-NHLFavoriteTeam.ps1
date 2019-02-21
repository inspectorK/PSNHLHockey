<#region HELP
.SYNOPSIS 
Get the current favorite team if it is set

.DESCRIPTION
This cmdlet gets the currently set favorite team

.PARAMETER Session
Get the currently set favorite team for the current session

.EXAMPLE
Get-NHLFavoriteTeam

This example will return the currently set favorite team.  This cmdlet returns null if there is not a favorite team set

#>
function Get-NHLFavoriteTeam {
    [CmdletBinding()]
    param (
    )

    process {
        if ($Global:PSNHL_Settings.settings.data.favoriteTeamName)
        {
            [NHLTeams]$FavoriteTeam = $Global:PSNHL_Settings.settings.data.favoriteTeamName
        }
        else
        {
            $FavoriteTeam = $null
        }
        
        return $FavoriteTeam
    }
}
