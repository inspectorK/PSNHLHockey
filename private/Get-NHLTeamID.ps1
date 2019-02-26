<#region HELP
.SYNOPSIS 
Get the ID associated with an NHL Team

.DESCRIPTION
This cmdlet returns the ID of a NHL Team as specified by the NHL.com api

.PARAMETER TeamName
The NHL team name to get.  The team name is an NHLTeam enum.

.EXAMPLE
Get-NHLTeamID -TeamName PhiladelphiaFlyers

This example will return the ID associated with the Philadelphia Flyers

#>

function Get-NHLTeamID {
    [CmdletBinding()]
    param (
    # Parameter help description
    [Parameter(Mandatory=$true, Position=0)]
    [NHLTeams]
    $TeamName
    )

    process {
        # for now, lets rely on the NHLTeam enum to get the ID
        if ($null -ne $TeamName)
        {
            return $TeamName.value__
        }
    }
}
