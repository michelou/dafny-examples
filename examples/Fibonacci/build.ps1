#!/usr/bin/env pwsh
#
# Copyright (c) 2018-2026 Stéphane Micheloud
#
# Licensed under the MIT License.
#

## https://powershellisfun.com/2023/04/24/using-the-requires-statement-in-powershell/
#Requires -Version 5.1

## only for interactive debugging !
$DEBUG = $false

#########################################################################
## Environment setup

$EXITCODE = 0

$EXE = ""
if ($PSVersionTable.PSVersion -lt "6.0" -or $IsWindows) {
  # Fix case when both the Windows and Linux builds of this program
  # are installed in the same directory.
  $EXE = '.exe'
}

$BASENAME = (Get-Item $PSScriptRoot).Basename
$ROOT_DIR = $PSScriptRoot
$PATH_SEP = [IO.Path]::PathSeparator
$SEP      = [IO.Path]::DirectorySeparatorChar

$SOURCE_DIR      = Join-Path -Path $ROOT_DIR   -ChildPath 'src'
$TARGET_DIR      = Join-Path -Path $ROOT_DIR   -ChildPath 'target'
$TARGET_DOCS_DIR = Join-Path -Path $TARGET_DIR -ChildPath 'docs'

$DAFNY_CMD = $Env:DAFNY_HOME + $SEP + 'Dafny' + $EXE
if (! (Test-Path -PathType Leaf -Path $DAFNY_CMD)) {
    Write-Error "Dafny compiler not found (check variable ""DAFNY_HOME"")"
    Cleanup 1
}
$JAVA_CMD = $Env:JAVA_HOME + $SEP + 'bin' + $SEP + 'java' + $EXE
if (! (Test-Path -PathType Leaf -Path $JAVA_CMD)) {
    Write-Error "Java command not found (check variable ""JAVA_HOME"")"
    Cleanup 1
}
$GO_CMD = $Env:GOROOT + $SEP + 'bin' + $SEP + 'go' + $EXE
if (! (Test-Path -PathType Leaf -Path $GO_CMD)) {
    Write-Error "Go command not found (check variable ""GOROOT"")"
    Cleanup 1
}
$MSBUILD_CMD = $Env:MSVS_HOME + $SEP + 'MSBuild' + $SEP + 'Current' + $SEP + 'bin' + $SEP + 'msbuild' + $EXE
if (! (Test-Path -PathType Leaf -Path $MSBUILD_CMD)) {
    Write-Error "MsBuild command not found (check variable ""MSVS_HOME"")"
    Cleanup 1
}
$RUSTC_CMD = $Env:CARGO_HOME + $SEP + 'bin' + $SEP + 'rustc' + $EXE
if (! (Test-Path -PathType Leaf -Path $RUSTC_CMD)) {
    Write-Error "Go command not found (check variable ""CARGO_HOME"")"
    Cleanup 1
}
$PS_VERSION = $PSVersionTable.PSVersion.ToString() 
$PROJECT_NAME = $BASENAME
$PROJECT_VERSION = '1.0-SNAPSHOT'

#########################################################################
## Script arguments

$COMMANDS = @()

## Possible values: SilentlyContinue, Stop, Continue, Inquire, Ignore, Suspend
$DebugPreference   = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$WarningPreference = 'Continue'

$TARGET = 'native'
$TIMER = $false
$VERBOSE = $false
$N = 0
foreach ($ARG in $args) {
    if ($ARG.StartsWith("-")) {
        ## option
        if ($ARG -ieq '-debug') { $DEBUG = $true; $DebugPreference='Continue'
        } elseif ($ARG -ieq "-help") { $COMMANDS = 'Print-Help'
        } elseif ($ARG -ieq "-target:cs") { $TARGET = 'cs'
        } elseif ($ARG -ieq "-target:go") { $TARGET = 'go'
        } elseif ($ARG -ieq "-target:java") { $TARGET = 'java'
        } elseif ($ARG -ieq "-target:native") { $TARGET = 'native'
        } elseif ($ARG -ieq "-target:rs") { $TARGET = 'rs'
        } elseif ($ARG -ieq "-timer"  ) { $TIMER = $true
        } elseif ($ARG -ieq "-verbose") { $VERBOSE = $true; $VerbosePreference = 'Continue'
        } else {
            Write-Error "Unknown option ""$ARG"""
            $EXITCODE = 1
            break
        }
    } else {
        ## subcommand
        if ($ARG -ieq 'clean') { $COMMANDS += 'Clean'
        } elseif ($ARG -ieq 'compile') { $COMMANDS += 'Compile'
        } elseif ($ARG -ieq 'help') { $COMMANDS = 'Print-Help'
        } elseif ($ARG -ieq 'run' ) { $COMMANDS += 'Compile', 'Run'
        } else {
            Write-Error "Unknown subcommand ""$ARG"""
            $EXITCODE = 1
            break
        }
        $N++
    }
}
switch ($TARGET) {
    'cs'     { $TARGET_EXT = '.exe' }
    'go'     { $TARGET_EXT = '.exe' }
    'java'   { $TARGET_EXT = '.jar' }
    'native' { $TARGET_EXT = '.exe' }
    'rs'     { $TARGET_EXT = '.exe' }
    default  { $TARGET_EXT = $null  }
}
$TARGET_FILE = $TARGET_DIR + $SEP + $PROJECT_NAME + $TARGET_EXT

Write-Debug "Options    : DEBUG=$DEBUG TARGET=$TARGET TIMER=$TIMER VERBOSE=$VERBOSE"
Write-Debug "Subcommands: $COMMANDS"
Write-Debug "Variables  : ""CARGO_HOME=$Env:CARGO_HOME"""
Write-Debug "Variables  : ""DAFNY_HOME=$Env:DAFNY_HOME"""
Write-Debug "Variables  : ""GIT_HOME=$Env:GIT_HOME"""
Write-Debug "Variables  : ""GOROOT=$Env:GOROOT"""
Write-Debug "Variables  : ""JAVA_HOME=$Env:JAVA_HOME"""
Write-Debug "Variables  : ""MSVS_HOME=$Env:MSVS_HOME"""

if ($TIMER) { $TIMER_START = Get-Date }

#########################################################################
## Subroutines

function Main
{
    foreach($COMMAND in $COMMANDS) {
        &$COMMAND
        if ($EXITCODE -ne 0) { exit $EXITCODE }
    }
    if ($TIMER) {
        $DURATION = New-TimeSpan -Start $TIMER_START -End (Get-Date)
        Write-Output "Total execution time: $DURATION"
    }
    Cleanup $EXITCODE
}

function Print-Help
{
    Write-Output "Usage: $BASENAME { <option> | <subcommand> }"
    Write-Output ""
    Write-Output "   Options:"
    Write-Output "     -debug          print commands executed by this script"
    Write-Output "     -target:<name>  select target language (default: native)"
    Write-Output "     -timer          print total execution time"
    Write-Output "     -verbose        print progress messages"
    Write-Output ""
    Write-Output "   Subcommands:"
    Write-Output "     clean           delete generated files"
    Write-Output "     compile         compile Dafny source files"
    Write-Output "     help            print this help message"
    Write-Output "     run             execute main program ""$($TARGET_FILE.Replace($ROOT_DIR, ''))"""
}

function Clean
{
    Delete-Directory -DirPath $TARGET_DIR
}

function Delete-Directory
{
    param (
        [string] $DirPath
    )
    if (Test-Path -PathType Container -Path $DirPath) {
        Write-Debug "[System.IO.Directory]::Delete('$DirPath', $true)"
        Write-Verbose "Delete directory ""$($DirPath.Replace($ROOT_DIR + $SEP, ''))"""
        try {
            #[System.IO.Directory]::Delete($DirPath, $true)
            Remove-Item -Path $DirPath -Force -Recurse
        } catch {
            Write-Error "Failed to delete directory ""$($DirPath.Replace($ROOT_DIR + $SEP, ''))"""
            $EXITCODE = 1
            return
        }
    }
}

function Compile
{
    if (! (Test-Path -PathType Container -Path $TARGET_DIR)) {
        $_ = New-Item -ItemType Directory -Path $TARGET_DIR
    }
    if (! (Test-Action-Required -FilePath "$TARGET_FILE" -DirPath "$SOURCE_DIR" -Pattern '*.dfy')) {
        return
    }
    $SOURCE_FILES = (Get-ChildItem -Path $SOURCE_JAVA_DIR -Include "*.dfy" -Recurse).FullName
    $N = $SOURCE_FILES.Count
    if ($N -eq 0) {
        Write-Warning "No Dafny source file found"
        return
    } elseif ($N -eq 1) { $N_FILES = "$N Dafny source file"
    } else { $N_FILES = "$N Dafny source files"
    }
    $BUILD_OPTS = @('--output', $TARGET_FILE)

    $OLD_PATH = $Env:PATH
    switch ($TARGET) {
        'cs'   { $Env:PATH = $Env:MSVS_HOME + $SEP + 'MSBuild' + $SEP + 'Current' + $SEP + 'Bin' + $SEP + 'Roslyn' + $PATH_SEP + $Env:PATH }
        'go'   { $Env:PATH = $($Env:GOROOT + $SEP + 'bin') + $PATH_SEP + $Env:GOBIN + $PATH_SEP + $Env:PATH }
        'java' { $Env:PATH = $($Env:JAVA_HOME + $SEP + 'bin') + $PATH_SEP + $Env:PATH }
        'rs'   { $Env:PATH = $($Env:CARGO_HOME + $SEP + 'bin') + $PATH_SEP + $Env:PATH }
    }
    Write-Debug "$DAFNY_CMD build $BUILD_OPTS $SOURCE_FILES"
    Write-Verbose "Compile $n_files to directory ""$($TARGET_DIR.Replace($ROOT_DIR, ''))"" with ""$TARGET"" target"
    &"$DAFNY_CMD" build $BUILD_OPTS $SOURCE_FILES
    if ($LASTEXITCODE -ne 0) {
        $Env:PATH = $OLD_PATH
        Write-Error "Failed to compile $n_files to directory ""$($TARGET_DIR.Replace($ROOT_DIR, ''))"" with target ""$TARGET"""
        Cleanup 1
    }
    $Env:PATH = $OLD_PATH
}

function Test-Action-Required
{
    param (
        [string] $FilePath,
        [string] $DirPath,
        [string] $Pattern
    )
    $REQUIRED = $false
    if (Test-Path -PathType Container -Path $DirPath) {
        if (Test-Path -PathType Leaf -Path $FilePath) {
            $FILE_LAST_TIME = (Get-Item $FilePath).LastWriteTime
            $DIR_LAST_TIME = (Get-ChildItem -Path $DirPath -Include $Pattern -Recurse | Sort LastWriteTime | Select -Last 1).LastWriteTime
            $REQUIRED = $FILE_LAST_TIME -lt $DIR_LAST_TIME
        } else {
            $REQUIRED = $true
        }
    }
    Write-Debug "REQUIRED=$REQUIRED ($Pattern)"
    return $REQUIRED
}

function Run
{
    if (! (Test-Path -PathType Leaf -Path $TARGET_FILE)) {
        Write-Error "Main program ""$($TARGET_FILE.Replace($ROOT_DIR, ''))"" not found"
        Cleanup 1
    }
    Write-Debug """$TARGET_FILE"""
    Write-Verbose "Execute Dafny program ""$($TARGET_FILE.Replace($ROOT_DIR, ''))"""
    &"$TARGET_FILE"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to execute Dafny program ""$($TARGET_FILE.Replace($ROOT_DIR, ''))"""
        Cleanup 1
    }
}

function Cleanup
{
    param (
        [int] $ExitCode
    )
    Write-Debug "ExitCode=$ExitCode"
    exit $ExitCode
}

#########################################################################
## Entry-point

Main
