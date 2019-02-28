<#
.SYNOPSIS 
Get the current NHL standings

.DESCRIPTION
This cmdlet uses the NHL.com API to return the current NHL standings by division, conference, or league

.PARAMETER StandingsType
The scope of standings to get.  Can be byDivision, byConference, or byLeague

.EXAMPLE
Get-NHLStandings -StandingsType byDivision

This example will get the current division standings

#>
function Get-NHLStandings {
    [CmdletBinding(DefaultParameterSetName = "GetTeamByFavorite")]
    param (
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [ValidateSet('byDivision','byConference','byLeague')]
    [System.String]
    $StandingsType
    )

    process {
        # declare automatics for processing
        [string]$RequestURIParams = ""
        [string]$RequestURI = "https://statsapi.web.nhl.com/api/v1/standings/"

        $RequestURIParams = $StandingsType

        try {
            $GetResponse = Invoke-RestMethod -Method Get -Uri ($RequestURI + $RequestURIParams)
        }
        catch {
            Write-Error -Message "Error requesting team info from NHL.com api. The attempted request was: $RequestURI"
        }

        return $GetResponse.records
    }
}