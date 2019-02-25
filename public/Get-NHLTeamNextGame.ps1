<#region HELP
.SYNOPSIS 
Get the next game an NHL Team is scheduled to play

.DESCRIPTION
This cmdlet uses the NHL.com API to return an NHL game object.  The team to retrieve can be passed 
via NHLTeam enum or integral ID

This cmdlet supports NHLFavoriteTeam functionality.  See Get-NHLFavoriteTeam and Set-NHLFavoriteTeam for more information

.PARAMETER TeamName
The NHL team.  The team name is an NHLTeam enum.

.PARAMETER TeamID
The NHL team ID as specified by the NHL.com api

.EXAMPLE
Get-NHLTeamNextGame -TeamName PhiladelphiaFlyers

This example uses the NHLTeam enum value "PhiladelphiaFlyers" to return the next scheduled
game information for the Philadelphia Flyers.

.EXAMPLE
Get-NHLTeamNextGame -TeamID 4

This example uses the NHL.com api team ID to return the next scheduled
game information for the Philadelphia Flyers.

.EXAMPLE
Set-FavoriteNHLTeam -TeamName PhiladelphiaFlyers
Get-NHLTeamNextGame

This example will set the favorite team for the user as the PhiladelphiaFlyers.  Now, Get-NHLTeamNextGame will get the favorite team's next game by default if not specified

#>

function Get-NHLTeamNextGame {
    [CmdletBinding(DefaultParameterSetName="GetNextGameByFavorite")]
    param (
    # Parameter help description
    [Parameter(Mandatory=$false, Position=0, ParameterSetName="GetNextGameByTeamName")]
    [NHLTeams]
    $TeamName,
    
    [Parameter(Mandatory=$false, ParameterSetName="GetNextGameByTeamID")]
    [Int32]
    $TeamID
    )

    process {
        # declare automatics for processing
        [string]$RequestURINextGameParams = "?expand=team.schedule.next"
        [string]$RequestURITeamParams = ""
        [string]$RequestURI = "https://statsapi.web.nhl.com/api/v1/teams/"

        # check if there is a favorite team set and we did not override with a TeamName
        if ($PSCmdlet.ParameterSetName -eq "GetNextGameByFavorite")
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

        if ($PSCmdlet.ParameterSetName -eq "GetNextGameByTeamName")
        {
            # if we got a name, we need to lookup the ID
            $TeamID = Get-NHLTeamID -TeamName $TeamName
        }
                    
        # Now lets validate the ID and set the api request params
        if ($TeamID -le 0)
        {
            Write-Error "Error processing TeamID : $TeamID : Cannot be a negative value"
            break
        }

        $RequestURITeamParams = $TeamID.ToString()
        
        # hopefully this works
        try {
            $GetResponse = Invoke-RestMethod -Method Get -Uri ($RequestURI + $RequestURITeamParams + $RequestURINextGameParams)
        }
        catch {
            # if we failed, just output what we tried for debugging
            Write-Error -Message "Error requesting team info from NHL.com api. The attempted request was: $RequestURI"
        }

        $GetResponse_NextGameInfo = $GetResponse.teams.nextGameSchedule.dates.games
        $NextGameInfo = [NHLTeamNextGameInfo]::new()
        $NextGameInfo.Venue = $GetResponse_NextGameInfo.venue.name
        $NextGameInfo.HomeTeam = $GetResponse_NextGameInfo.teams.home.team.id
        $NextGameInfo.AwayTeam = $GetResponse_NextGameInfo.teams.away.team.id
        $NextGameInfo.GameDate = Get-Date $GetResponse_NextGameInfo.gameDate

        return $NextGameInfo
    }
}
