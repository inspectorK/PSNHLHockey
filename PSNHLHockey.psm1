# PSNHLHockey.psm1

# Define Globals
# load global Team:ID mapping
enum NHLTeams {
    NewJerseyDevils = 1
    NewYorkIslanders = 2
    NewYorkRangers = 3
    PhiladelphiaFlyers = 4
    PittsburghPenguins = 5
    BostonBruins = 6
    BuffaloSabres = 7
    MontrealCanadiens = 8
    OttawaSenators = 9
    TorontoMapleLeafs = 10
    CarolinaHurricanes = 12
    FloridaPanthers = 13
    TampaBayLightning = 14
    WashingtonCapitals = 15
    ChicagoBlackhawks = 16
    DetroitRedWings = 17
    NashvillePredators = 18
    StLouisBlues = 19
    CalgaryFlames = 20
    ColoradoAvalanche = 21
    EdmontonOilers = 22
    VancouverCanucks = 23
    AnaheimDucks = 24
    DallasStars = 25
    LosAngelesKings = 26
    SanJoseSharks = 28
    ColumbusBlueJackets = 29
    MinnesotaWild = 30
    WinnipegJets = 52
    ArizonaCoyotes = 53
    VegasGoldenKnights = 54
}

# Define custom classes
class NHLTeamNextGameInfo
{
   [DateTime]$GameDate
   [NHLTeams]$HomeTeam
   [NHLTeams]$AwayTeam
   [System.String]$Venue
}

class NHLTeamPreviousGameInfo
{
   [DateTime]$GameDate
   [String]$GameState
   [NHLTeams]$HomeTeam
   [int]$HomeScore
   [NHLTeams]$AwayTeam
   [int]$AwayScore
   [System.String]$Venue
}

[xml]$Global:PSNHL_SETTINGS = Get-Content -Path (Join-Path $PSScriptRoot "settings.xml")


$public = Get-ChildItem -Path (Join-Path $PSScriptRoot "public") -Recurse -Filter *.ps1
$private = Get-ChildItem -Path (Join-Path $PSScriptRoot "private") -Recurse -Filter *.ps1

#Load public functions
foreach ($import in $public)
{
   try {. $import.FullName}
   catch {Write-Error ("Failed to import public function {0}" -f $import.BaseName)}
}

#Load private functions
foreach ($import in $private)
{
   try {. $import.FullName}
   catch {Write-Error ("Failed to import private function {0}" -f $import.BaseName)}
}

#Export only public functions
Export-ModuleMember -Function $public.BaseName

