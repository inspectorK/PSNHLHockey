<#region HELP
.SYNOPSIS 
Get an NHL Team

.DESCRIPTION
This cmdlet uses the NHL.com API to return an NHL team object.  The team to retrieve can be passed 
via NHLTeam enum or integral ID

.PARAMETER TeamName
The NHL team name to get.  The team name is an NHLTeam enum.

.PARAMETER TeamID
The NHL team ID as specified by the NHL.com api

.EXAMPLE
Get-NHLTeam -TeamName PhiladelphiaFlyers

This example uses the NHLTeam enum value "PhiladelphiaFlyers" to return the team information for the Philadelphia Flyers

.EXAMPLE
Get-NHLTeam -TeamID 4

This example uses the integral NHL.com api id to return the team information for the Philadelphia Flyers

.EXAMPLE
Get-NHLTeam -All

This example returns all NHL teams

#>

function Get-NHLTeam {
    [CmdletBinding()]
    param (
    # Parameter help description
    [Parameter(Mandatory=$false, ParameterSetName="GetTeamByTeamName")]
    [NHLTeams]
    $TeamName,
    
    [Parameter(Mandatory=$false, ParameterSetName="GetTeamByID")]
    [Int32]
    $TeamID,

    [Parameter(Mandatory=$false, ParameterSetName="GetAllTeams")]
    [switch]
    $All
    )

    process {
        # declare automatics for processing
        [string]$RequestURIParams = ""
        [string]$RequestURI = "https://statsapi.web.nhl.com/api/v1/teams/"

        if ($PSCmdlet.ParameterSetName -ne "GetAllTeams")
        {
            # if we got a name, we need to lookup the ID
            $TeamID = Get-NHLTeamID -TeamName $TeamName
            
            # Now lets validate the ID and set the api request params
            if ($TeamID -le 0)
            {
                Write-Error "Error processing TeamID : $TeamID : Cannot be a negative value"
                break
            }

            $RequestURIParams = $TeamID.ToString()
        }
        
        try {
            $GetResponse = Invoke-RestMethod -Method Get -Uri ($RequestURI + $RequestURIParams)
        }
        catch {
            Write-Error -Message "Error requesting team info from NHL.com api. The attempted request was: $RequestURI"
        }

        return $GetResponse.teams
    }
}
