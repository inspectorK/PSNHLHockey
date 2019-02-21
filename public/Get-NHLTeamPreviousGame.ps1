<#region HELP
.SYNOPSIS 
Get the previous game an NHL Team has played

.DESCRIPTION
This cmdlet uses the NHL.com API to return an NHL game object.  The team to retrieve can be passed 
via NHLTeam enum or integral ID

.PARAMETER TeamName
The NHL team.  The team name is an NHLTeam enum.

.PARAMETER TeamID
The NHL team ID as specified by the NHL.com api

.EXAMPLE
Get-NHLTeamPreviousGame -TeamName PhiladelphiaFlyers

This example uses the NHLTeam enum value "PhiladelphiaFlyers" to return the previously played
game information for the Philadelphia Flyers.

.EXAMPLE
Get-NHLTeamPreviousGame -TeamID 4

This example uses the NHL.com api team ID to return the previously played
game information for the Philadelphia Flyers.

#>

function Get-NHLTeamPreviousGame {
    [CmdletBinding()]
    param (
    # Parameter help description
    [Parameter(Mandatory=$false, Position=0, ParameterSetName="GetPreviousGameByTeamName")]
    [NHLTeams]
    $TeamName,
    
    [Parameter(Mandatory=$false, ParameterSetName="GetPreviousGameByTeamID")]
    [Int32]
    $TeamID
    )

    process {
        # declare automatics for processing
        [string]$RequestURINextGameParams = "?expand=team.schedule.previous"
        [string]$RequestURITeamParams = ""
        [string]$RequestURI = "https://statsapi.web.nhl.com/api/v1/teams/"

        if ($PSCmdlet.ParameterSetName -eq "GetPreviousGameByTeamName")
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

        return $GetResponse.teams.previousGameSchedule.dates.games
    }
}
