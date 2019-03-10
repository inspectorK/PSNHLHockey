<#
.SYNOPSIS 
Get the team statistics for a specified NHLTeam

.DESCRIPTION
This cmdlet uses the NHL.com API to return the team statistics for a supplied NHLTeam

This cmdlet supports NHLFavoriteTeam functionality.  See Get-NHLFavoriteTeam and Set-NHLFavoriteTeam for more information

.PARAMETER TeamName
The NHLTeam for which to return the team statistics

.PARAMETER TeamID
The NHLTeam ID for which to return the team statistics

.PARAMETER Relative
Return only the league relative team statistics

.PARAMETER Absolute
Return the absolute numerical team statistics

.EXAMPLE
Get-NHLTeamStatistics -NHLTeam PhiladelphiaFlyers

This example will get the NHLTeam statistics for the Philadelphia Flyers

.EXAMPLE
Set-FavoriteNHLTeam -TeamName PhiladelphiaFlyers
Get-NHLTeamStatistics

This example will set the favorite team for the user as the PhiladelphiaFlyers.  Now, Get-NHLTeamStatistics will get the statistics for the favorite team by default if not specified


#>
function Get-NHLTeamStatistics {
    [CmdletBinding(DefaultParameterSetName = "GetTeamStatsByFavorite")]
    param (
    # Parameter help description
    [Parameter(Mandatory=$false, ParameterSetName="GetTeamStatsByTeamName")]
    [NHLTeams]
    $TeamName,
    
    [Parameter(Mandatory=$false, ParameterSetName="GetTeamStatsByID")]
    [Int32]
    $TeamID,

    [Parameter(Mandatory=$false)]
    [switch]
    $Absolute,

    [Parameter(Mandatory=$false)]
    [switch]
    $Relative    
    )

    process {
        # declare automatics for processing
        [string]$RequestURIParams = ""
        [string]$RequestURI = "https://statsapi.web.nhl.com/api/v1/teams/"

        if (!$All)
        {
            # check if there is a favorite team set and we did not override with a TeamName
            if ($PSCmdlet.ParameterSetName -eq "GetTeamStatsByFavorite")
            {
                if ($Global:PSNHL_SETTINGS.settings.data.favoriteTeamID)
                {
                    $TeamID = $Global:PSNHL_SETTINGS.settings.data.favoriteTeamID
                }
                else 
                {
                    Write-Error "There is no favorite NHLTeam currently set.  Use Set-NHLFavoriteTeam to set a favorite team"
                    break
                }
            }


            if ($PSCmdlet.ParameterSetName -eq "GetTeamStatsByTeamName")
            {
                # if we got a name, we need to lookup the ID and use that overriding favorite team
                $TeamID = Get-NHLTeamID -TeamName $TeamName
            }

            # Now lets validate the ID and set the api request params
            if ($TeamID -le 0)
            {
                Write-Error "Error processing TeamID : $TeamID : Cannot be a negative value"
                break
            }

            $RequestURIParams = $TeamID.ToString()
            $RequestURIParams += "?expand=team.stats"
        }
        
        try {
            $GetResponse = Invoke-RestMethod -Method Get -Uri ($RequestURI + $RequestURIParams)
        }
        catch {
            Write-Error -Message "Error requesting team info from NHL.com api. The attempted request was: $RequestURI"
        }

        # Return stats client asked for
        if ($Relative)
        {
            return $GetResponse.teams.teamstats.splits.stat[1] 
        }
        elseif ($Absolute)
        {
            return $GetResponse.teams.teamstats.splits.stat[0]
        }
        else
        {
            return $GetResponse.teams.teamstats.splits.stat
        }

    }
}