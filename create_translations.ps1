[CmdletBinding()]
param (
    [string]
    $Path,
    [string[]]
    $Languages = @('NLD'),
    [string[]]
    $Targets = @('nl-NL'),
    [bool]
    $CheckForError = 1,
    [bool]
    $OverwriteFiles = 0
)

function IncorrectRegex {
    param (
        [string] $Language
    )
    
    return '<note from="Developer"((?!\['+ $Language + '\s=\s([^\[\]])*\]).)*$'
}

function FindRegex {
    param (
        [string] $Language
    )
    
    return '<note from="Developer".*>.*\[' + $Language + '\s=\s([^\[\]]*)\].*<\/note>'
}

function ReplaceTargetRegex {
    param (
        [string] $Target
    )
    
    return '<file datatype="xml" source-language="en-US" target-language="' + $Target + '"'
}

function CheckParameterErrors {
    if ($Path.Length -le 0) {
        throw '-Path paramater not set'
        exit 1
    }
    
    if(-Not ($Languages.Count -eq $targets.Count) ) {
        throw 'Not the same amount of targets (' + $Targets + ') and languages (' + $Languages + ')'
        exit 1
    }
}


CheckParameterErrors

$GlobalFile = (Get-ChildItem (Join-Path $Path *.g.xlf))

if (-not $GlobalFile) {
    throw 'Global translation file (*.g.xlf) not found in path "' + $Path + '"'
    exit 1
}

$ReplaceRegex = '<target state="translated">$1</target>
          $0'

$FindTargetRegex = '<file datatype="xml" source-language="en-US" target-language="([^"]*)"'

$ProjectName = $GlobalFile.Name.split('.')[0]

Write-Host ('Translating to languages ' + $Languages + ' with targets ' + $Targets)

for ($i = 0; $i -lt $Languages.COUNT(); $i++) {
    $Content = Get-Content $GlobalFile.FullName

    $CurrentLanguage = $Languages[$i]
    $CurrentTarget = $Targets[$i]

    Write-Host ('Processing ' + $CurrentLanguage + ' ' + $CurrentTarget)

    $incorrect_regex = IncorrectRegex($CurrentLanguage)

    if ($CheckForError) {
        if ($Content -match $incorrect_regex) {
            Write-Warning ('Captions incomplete or incorrect for language ' + $CurrentLanguage + '. Use "' + $incorrect_regex + '" in the global translation file to find them.')
            Write-Warning 'Or disable the check with -CheckForError 0 parameter'
            Continue
        }
    }

    $FindRegex = FindRegex($CurrentLanguage)
    $ReplaceTargetRegex = ReplaceTargetRegex($CurrentTarget)

    $Content = $Content -replace $FindRegex, $ReplaceRegex
    $Content = $Content -replace $FindTargetRegex, $ReplaceTargetRegex 

    $Outfile = ((Join-Path $Path $ProjectName ) + '.' + $CurrentTarget + '.xlf')

    if (-not $OverwriteFiles) {
        if (Test-Path $Outfile) {
            Write-Warning ('File not created, it already exists: ' + $Outfile)
            Write-Warning 'Delete file or use -OverwriteFiles parameter'
            Continue
        }
    }
        
    $Content | Out-File $Outfile -Encoding UTF8
    Write-Host ('Created ' + $Outfile)
}

Write-Host 'Done :)'
