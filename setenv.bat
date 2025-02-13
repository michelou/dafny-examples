@echo off
setlocal enabledelayedexpansion

@rem only for interactive debugging !
set _DEBUG=0

@rem #########################################################################
@rem ## Environment setup

set _EXITCODE=0

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end

@rem #########################################################################
@rem ## Main

if %_HELP%==1 (
    call :help
    exit /b !_EXITCODE!
)

set _GIT_PATH=
set _GOLANG_PATH=
set _MSYS_PATH=
set _VSCODE_PATH=

call :dafny
if not %_EXITCODE%==0 goto end

call :git
if not %_EXITCODE%==0 goto end

call :golang
if not %_EXITCODE%==0 (
    @rem optional
    echo %_WARNING_LABEL% Go installation not found ^(optional^) 1>&2
    set _EXITCODE=0
)

call :java 17 "temurin"
if not %_EXITCODE%==0 goto end

call :msvs
if not %_EXITCODE%==0 (
    @rem optional
    echo %_WARNING_LABEL% MS Visual Studio installation not found ^(optional^) 1>&2
    set _EXITCODE=0
)
call :msys
if not %_EXITCODE%==0 goto end

call :rust
if not %_EXITCODE%==0 (
    @rem optional
    echo %_WARNING_LABEL% Rust installation not found ^(optional^) 1>&2
    set _EXITCODE=0
)
call :vscode
if not %_EXITCODE%==0 (
    @rem optional
    echo %_WARNING_LABEL% VS Code installation not found ^(optional^) 1>&2
    set _EXITCODE=0
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

set "_GOPATH=%USERPROFILE%\go"
set "_GOBIN=%_GOPATH%\bin"
goto :eof

:env_colors
@rem ANSI colors in standard Windows 10 shell
@rem see https://gist.github.com/mlocati/#file-win10colors-cmd

@rem normal foreground colors
set _NORMAL_FG_BLACK=[30m
set _NORMAL_FG_RED=[31m
set _NORMAL_FG_GREEN=[32m
set _NORMAL_FG_YELLOW=[33m
set _NORMAL_FG_BLUE=[34m
set _NORMAL_FG_MAGENTA=[35m
set _NORMAL_FG_CYAN=[36m
set _NORMAL_FG_WHITE=[37m

@rem normal background colors
set _NORMAL_BG_BLACK=[40m
set _NORMAL_BG_RED=[41m
set _NORMAL_BG_GREEN=[42m
set _NORMAL_BG_YELLOW=[43m
set _NORMAL_BG_BLUE=[44m
set _NORMAL_BG_MAGENTA=[45m
set _NORMAL_BG_CYAN=[46m
set _NORMAL_BG_WHITE=[47m

@rem strong foreground colors
set _STRONG_FG_BLACK=[90m
set _STRONG_FG_RED=[91m
set _STRONG_FG_GREEN=[92m
set _STRONG_FG_YELLOW=[93m
set _STRONG_FG_BLUE=[94m
set _STRONG_FG_MAGENTA=[95m
set _STRONG_FG_CYAN=[96m
set _STRONG_FG_WHITE=[97m

@rem strong background colors
set _STRONG_BG_BLACK=[100m
set _STRONG_BG_RED=[101m
set _STRONG_BG_GREEN=[102m
set _STRONG_BG_YELLOW=[103m
set _STRONG_BG_BLUE=[104m

@rem we define _RESET in last position to avoid crazy console output with type command
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m
set _RESET=[0m
goto :eof

@rem input parameter: %*
@rem output parameters: _BASH, _HELP, _VERBOSE
:args
set _BASH=0
set _HELP=0
set _BASH=0
set _VERBOSE=0
:args_loop
set "__ARG=%~1"
if not defined __ARG goto args_done

if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-bash" ( set _BASH=1
    ) else if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-help" ( set _HELP=1
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="help" ( set _HELP=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
)
shift
goto args_loop
:args_done
call :drive_name "%_ROOT_DIR%"
if not %_EXITCODE%==0 goto :eof
if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _BASH=%_BASH% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: _HELP=%_HELP% 1>&2
    echo %_DEBUG_LABEL% Variables  : _DRIVE_NAME=%_DRIVE_NAME% 1>&2
)
goto :eof

@rem input parameter: %1: path to be substituted
@rem output parameter: _DRIVE_NAME (2 characters: letter + ':')
:drive_name
set "__GIVEN_PATH=%~1"
@rem remove trailing path separator if present
if "%__GIVEN_PATH:~-1,1%"=="\" set "__GIVEN_PATH=%__GIVEN_PATH:~0,-1%"

@rem https://serverfault.com/questions/62578/how-to-get-a-list-of-drive-letters-on-a-system-through-a-windows-shell-bat-cmd
set __DRIVE_NAMES=F:G:H:I:J:K:L:M:N:O:P:Q:R:S:T:U:V:W:X:Y:Z:
for /f %%i in ('wmic logicaldisk get deviceid ^| findstr :') do (
    set "__DRIVE_NAMES=!__DRIVE_NAMES:%%i=!"
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% __DRIVE_NAMES=%__DRIVE_NAMES% ^(WMIC^) 1>&2
if not defined __DRIVE_NAMES (
    echo %_ERROR_LABEL% No more free drive name 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f "tokens=1,2,*" %%f in ('subst') do (
    set "__SUBST_DRIVE=%%f"
    set "__SUBST_DRIVE=!__SUBST_DRIVE:~0,2!"
    set "__SUBST_PATH=%%h"
    @rem Windows local file systems are not case sensitive (by default)
    if /i "!__SUBST_DRIVE!"=="!__GIVEN_PATH:~0,2!" (
        set _DRIVE_NAME=!__SUBST_DRIVE:~0,2!
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        ) else if %_VERBOSE%==1 ( echo Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        )
        goto :eof
    ) else if "!__SUBST_PATH!"=="!__GIVEN_PATH!" (
        set "_DRIVE_NAME=!__SUBST_DRIVE!"
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        ) else if %_VERBOSE%==1 ( echo Select drive !_DRIVE_NAME! for which a substitution already exists 1>&2
        )
        goto :eof
    )
)
for /f "tokens=1,2,*" %%i in ('subst') do (
    set __USED=%%i
    call :drive_names "!__USED:~0,2!"
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% __DRIVE_NAMES=%__DRIVE_NAMES% ^(SUBST^) 1>&2

set "_DRIVE_NAME=!__DRIVE_NAMES:~0,2!"
if /i "%_DRIVE_NAME%"=="%__GIVEN_PATH:~0,2%" goto :eof

if %_DEBUG%==1 ( echo %_DEBUG_LABEL% subst "%_DRIVE_NAME%" "%__GIVEN_PATH%" 1>&2
) else if %_VERBOSE%==1 ( echo Assign drive %_DRIVE_NAME% to path "!__GIVEN_PATH:%USERPROFILE%=%%USERPROFILE%%!" 1>&2
)
subst "%_DRIVE_NAME%" "%__GIVEN_PATH%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to assign drive %_DRIVE_NAME% to path "!__GIVEN_PATH:%USERPROFILE%=%%USERPROFILE%%!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem input parameter: %1=Used drive name
@rem output parameter: __DRIVE_NAMES
:drive_names
set "__USED_NAME=%~1"
set "__DRIVE_NAMES=!__DRIVE_NAMES:%__USED_NAME%=!"
goto :eof

:help
if %_VERBOSE%==1 (
    set __BEG_P=%_STRONG_FG_CYAN%
    set __BEG_O=%_STRONG_FG_GREEN%
    set __BEG_N=%_NORMAL_FG_YELLOW%
    set __END=%_RESET%
) else (
    set __BEG_P=
    set __BEG_O=
    set __BEG_N=
    set __END=
)
echo Usage: %__BEG_O%%_BASENAME% { ^<option^> ^| ^<subcommand^> }%__END%
echo.
echo   %__BEG_P%Options:%__END%
echo     %__BEG_O%-bash%__END%       start Git bash shell instead of Windows command prompt
echo     %__BEG_O%-debug%__END%      print commands executed by this script
echo     %__BEG_O%-verbose%__END%    print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%help%__END%        print this help message
goto :eof

@rem output parameter: _DAFNY_HOME
:dafny
set _DAFNY_HOME=

set __DAFNY_CMD=
for /f "delims=" %%f in ('where dafny.exe 2^>NUL') do set "__DAFNY_CMD=%%f"
if defined __ADACTK_CMD (
    for /f "delims=" %%i in ("%__ADACTL_CMD%") do set "_DAFNY_HOME=%%f"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Dafny executable found in PATH 1>&2
) else if defined DAFNY_HOME (
    set "_DAFNY_HOME=%DAFNY_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable ADACTL_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\dafny\" ( set "_DAFNY_HOME=!__PATH!\dafny"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\dafny*" 2^>NUL') do set "_DAFNY_HOME=!__PATH!\%%f"
        if not defined _DAFNY_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\dafny-*" 2^>NUL') do set "_DAFNY_HOME=!__PATH!\%%f"
        )
    )
    if defined _DAFNY_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Dafny installation directory "!_DAFNY_HOME!" 1>&2
    )
)
if not exist "%_DAFNY_HOME%\dafny.exe" (
    echo %_ERROR_LABEL% Dafny executable not found ^("%_DAFNY_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

@rem output parameters: _GIT_HOME, _GIT_PATH
:git
set _GIT_HOME=
set _GIT_PATH=

set __GIT_CMD=
for /f "delims=" %%f in ('where git.exe 2^>NUL') do set "__GIT_CMD=%%f"
if defined __GIT_CMD (
    for /f "delims=" %%i in ("%__GIT_CMD%") do set "__GIT_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__GIT_BIN_DIR!.") do set "_GIT_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Git executable found in PATH 1>&2
    @rem Executable git.exe is present both in bin\ and \mingw64\bin\
    if not "!_GIT_HOME:mingw=!"=="!_GIT_HOME!" (
        for /f "delims=" %%f in ("!_GIT_HOME!\..") do set "_GIT_HOME=%%f"
    )
    @rem keep _GIT_PATH undefined since executable already in path
    goto :eof
) else if defined GIT_HOME (
    set "_GIT_HOME=%GIT_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GIT_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Git\" ( set "_GIT_HOME=!__PATH!\Git"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        if not defined _GIT_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Git*" 2^>NUL') do set "_GIT_HOME=!__PATH!\%%f"
        )
    )
    if defined _GIT_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Git installation directory "!_GIT_HOME!" 1>&2
    )
)
if not exist "%_GIT_HOME%\bin\git.exe" (
    echo %_ERROR_LABEL% Git executable not found ^("%_GIT_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GIT_PATH=;%_GIT_HOME%\bin;%_GIT_HOME%\mingw64\bin;%_GIT_HOME%\usr\bin"
goto :eof

@rem output parameters: _GOLANG_HOME, _GOLANG_PATH
:golang
set _GOLANG_HOME=
set _GOLANG_PATH=

set __GO_CMD=
for /f "delims=" %%f in ('where go.exe 2^>NUL') do set "__GO_CMD=%%f"
if defined __GO_CMD (
    for /f "delims=" %%i in ("%__GO_CMD%") do set "__GO_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__GO_BIN_DIR!.") do set "_GOLANG_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Go executable found in PATH 1>&2
    @rem keep _GOLANG_PATH undefined since executable already in path
    goto :eof
) else if defined GO_HOME (
    set "_GOLANG_HOME=%GO_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable GO_HOME
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\Go\" ( set "_GOLANG_HOME=!__PATH!\Go"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Go-*" 2^>NUL') do set "_GOLANG_HOME=!__PATH!\%%f"
        if not defined _GOLANG_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\Go-*" 2^>NUL') do set "_GOLANG_HOME=!__PATH!\%%f"
        )
    )
    if defined _GOLANG_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Go installation directory "!_GOLANG_HOME!" 1>&2
    )
)
if not exist "%_GOLANG_HOME%\bin\go.exe" (
    echo %_ERROR_LABEL% Go executable not found ^("%_GOLANG_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_GOLANG_PATH=;%_GOLANG_HOME%\bin"
goto :eof

@rem input parameters:%1=required version %2=vendor 
@rem output parameter: _JAVA_HOME (resp. JAVA11_HOME)
:java
set _JAVA_HOME=

set __VERSION=%~1
set __VENDOR=%~2
if not defined __VENDOR ( set __JDK_NAME=jdk-%__VERSION%
) else ( set __JDK_NAME=jdk-%__VENDOR%-%__VERSION%
)
set __JAVAC_CMD=
for /f "delims=" %%f in ('where javac.exe 2^>NUL') do (
    set "__JAVAC_CMD=%%f"
    @rem we ignore Scoop managed Java installation
    if not "!__JAVAC_CMD:scoop=!"=="!__JAVAC_CMD!" set __JAVAC_CMD=
)
if defined __JAVAC_CMD (
    call :jdk_version "%__JAVAC_CMD%"
    if !_JDK_VERSION!==%__VERSION% (
        for /f "delims=" %%i in ("%__JAVAC_CMD%") do set "__BIN_DIR=%%~dpi"
        for /f "delims=" %%f in ("%__BIN_DIR%") do set "_JAVA_HOME=%%~dpf"
    ) else (
        echo %_ERROR_LABEL% Required JDK installation not found ^("%__JDK_NAME%"^) 1>&2
        set _EXITCODE=1
        goto :eof
    )
)
if defined JAVA_HOME (
    set "_JAVA_HOME=%JAVA_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable JAVA_HOME 1>&2
) else (
    set __PATH=C:\opt
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\%__JDK_NAME%*" 2^>NUL') do set "_JAVA_HOME=!__PATH!\%%f"
    if not defined _JAVA_HOME (
        set "__PATH=%ProgramFiles%\Java"
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\%__JDK_NAME%*" 2^>NUL') do set "_JAVA_HOME=!__PATH!\%%f"
    )
    if defined _JAVA_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Java SDK installation directory "!_JAVA_HOME!" 1>&2
    )
)
if not exist "%_JAVA_HOME%\bin\javac.exe" (
    echo %_ERROR_LABEL% Executable javac.exe not found ^("%_JAVA_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
call :jdk_version "%_JAVA_HOME%\bin\javac.exe"
set "_JAVA!_JDK_VERSION!_HOME=%_JAVA_HOME%"
goto :eof

@rem input parameter: %1=javac file path
@rem output parameter: _JDK_VERSION
:jdk_version
set "__JAVAC_CMD=%~1"
if not exist "%__JAVAC_CMD%" (
    echo %_ERROR_LABEL% Command javac.exe not found ^("%__JAVAC_CMD%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set __JAVAC_VERSION=
for /f "usebackq tokens=1,*" %%i in (`"%__JAVAC_CMD%" -version 2^>^&1`) do set __JAVAC_VERSION=%%j
set "__PREFIX=%__JAVAC_VERSION:~0,2%"
@rem either 1.7, 1.8 or 11..18
if "%__PREFIX%"=="1." ( set _JDK_VERSION=%__JAVAC_VERSION:~2,1%
) else ( set _JDK_VERSION=%__PREFIX%
)
goto :eof

@rem output parameters: _MSVS_HOME
:msvs
for /f "delims=" %%i in ('vswhere ^| findstr /b installationPath') do (
    set "__PATH=%%i"
    set "_MSVS_HOME=!__PATH:InstallationPath: =!"
)
goto :eof

@rem output parameters: _MSYS_HOME, _MSYS_PATH
:msys
set _MSYS_HOME=
set _MSYS_PATH=

set __MAKE_CMD=
for /f "delims=" %%f in ('where make.exe 2^>NUL') do set "__MAKE_CMD=%%f"
if defined __MAKE_CMD (
    for /f "delims=" %%i in ("%__MAKE_CMD%") do set "__MAKE_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__MAKE_BIN_DIR!.") do set "_MSYS_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of GNU Make executable found in PATH 1>&2
    @rem keep _MSYS_PATH undefined since executable already in path
    goto :eof
) else if defined MSYS_HOME (
    set "_MSYS_HOME=%MSYS_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable MSYS_HOME 1>&2
) else (
    set "__PATH=%ProgramFiles%"
    for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    if not defined _MSYS_HOME (
        set __PATH=C:\opt
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\msys*" 2^>NUL') do set "_MSYS_HOME=!__PATH!\%%f"
    )
)
if not exist "%_MSYS_HOME%\usr\bin\make.exe" (
    echo %_ERROR_LABEL% GNU Make executable not found ^("%_MSYS_HOME%"^) 1>&2
    set _MSYS_HOME=
    set _EXITCODE=1
    goto :eof
)
@rem 1st path -> (make.exe, python.exe), 2nd path -> gcc.exe
set "_MSYS_PATH=;%_MSYS_HOME%\usr\bin;%_MSYS_HOME%\mingw64\bin"
goto :eof

@rem output parameters: _CARGO_HOME, _CARGO_PATH
:rust
set _CARGO_HOME=
set _CARGO_PATH=

set __CARGO_CMD=
for /f "delims=" %%f in ('where cargo.exe 2^>NUL') do set "__CARGO_CMD=%%f"
if defined __CARGO_CMD (
    for /f "delims=" %%i in ("%__CARGO_CMD%") do set "__CARGO_BIN_DIR=%%~dpi"
    for /f "delims=" %%f in ("!__CARGO_BIN_DIR!\.") do set "_CARGO_HOME=%%~dpf"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of Rust executable found in PATH 1>&2
    goto :eof
) else if defined CARGO_HOME (
    set "_CARGO_HOME=%CARGO_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable CARGO_HOME 1>&2
) else if exist "%USERPROFILE%\.cargo\bin\cargo.exe" (
    set "_CARGO_HOME=%USERPROFILE%\.cargo"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default Rust installation directory "!_CARGO_HOME!" 1>&2
)
if not exist "%_CARGO_HOME%\bin\cargo.exe" (
    echo %_ERROR_LABEL% Cargo executable not found ^("%_CARGO_HOME%"^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_CARGO_PATH=;%_CARGO_HOME%\bin"
goto :eof

@rem output parameters: _VSCODE_HOME, _VSCODE_PATH
:vscode
set _VSCODE_HOME=
set _VSCODE_PATH=

set __CODE_CMD=
for /f "delims=" %%f in ('where code.exe 2^>NUL') do set "__CODE_CMD=%%f"
if defined __CODE_CMD (
    for /f "delims=" %%i in ("%__CODE_CMD%") do set "_VSCODE_HOME=%%~dpi"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using path of VSCode executable found in PATH 1>&2
    @rem keep _VSCODE_PATH undefined since executable already in path
    goto :eof
) else if defined VSCODE_HOME (
    set "_VSCODE_HOME=%VSCODE_HOME%"
    if %_DEBUG%==1 echo %_DEBUG_LABEL% Using environment variable VSCODE_HOME 1>&2
) else (
    set __PATH=C:\opt
    if exist "!__PATH!\VSCode\" ( set "_VSCODE_HOME=!__PATH!\VSCode"
    ) else (
        for /f "delims=" %%f in ('dir /ad /b "!__PATH!\VSCode-1*" 2^>NUL') do set "_VSCODE_HOME=!__PATH!\%%f"
        if not defined _VSCODE_HOME (
            set "__PATH=%ProgramFiles%"
            for /f "delims=" %%f in ('dir /ad /b "!__PATH!\VSCode-1*" 2^>NUL') do set "_VSCODE_HOME=!__PATH!\%%f"
        )
    )
    if defined _VSCODE_HOME (
        if %_DEBUG%==1 echo %_DEBUG_LABEL% Using default VSCode installation directory "!_VSCODE_HOME!" 1>&2
    )
)
if not exist "%_VSCODE_HOME%\code.exe" (
    echo %_ERROR_LABEL% VSCode executable not found ^("%_VSCODE_HOME%"^) 1>&2
    if exist "%_VSCODE_HOME%\Code - Insiders.exe" (
        echo %_WARNING_LABEL% It looks like you've installed an Insider version of VSCode 1>&2
    )
    set _EXITCODE=1
    goto :eof
)
set "_VSCODE_PATH=;%_VSCODE_HOME%"
goto :eof

:print_env
set __VERBOSE=%1
set __VERSIONS_LINE1=
set __VERSIONS_LINE2=
set __VERSIONS_LINE3=
set __WHERE_ARGS=
where /q "%CARGO_HOME%\bin:cargo.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%CARGO_HOME%\bin\cargo.exe" --version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% cargo %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%CARGO_HOME%\bin:cargo.exe"
)
where /q "%CARGO_HOME%\bin:rustc.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%CARGO_HOME%\bin\rustc.exe" --version') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% rustc %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%CARGO_HOME%\bin:rustc.exe"
)
where /q "%DAFNY_HOME%:dafny.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,* delims=+" %%i in ('"%DAFNY_HOME%\dafny.exe" --version 2^>^&1') do set "__VERSIONS_LINE1=%__VERSIONS_LINE1% dafny %%i,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%DAFNY_HOME%:dafny.exe"
)
where /q "%JAVA_HOME%\bin:javac.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('call "%JAVA_HOME%\bin\javac.exe" -version 2^>^&1') do set "__VERSIONS_LINE2=%__VERSIONS_LINE2% javac %%j,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%JAVA_HOME%\bin:javac.exe"
)
where /q "%VSCODE_HOME%\bin:code.cmd"
if %ERRORLEVEL%==0 (
    set __VSCODE_VERSION=
    for /f "tokens=*" %%i in ('"%VSCODE_HOME%\bin\code.cmd" --version') do (
        if not defined __VSCODE_VERSION (
            set __VSCODE_VERSION=%%i
            set "__VERSIONS_LINE2=%__VERSIONS_LINE2% code !__VSCODE_VERSION!,"
        )
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%VSCODE_HOME%\bin:code.cmd"
)
where /q "%GOROOT%\bin:go.exe"
if %ERRORLEVEL%==0 (
    setlocal enabledelayedexpansion
    for /f "tokens=1,2,3,*" %%i in ('"%GOROOT%\bin\go.exe" version') do set "__TOKEN=%%k"
    set "__VERSIONS_LINE2=%__VERSIONS_LINE2% go !__TOKEN:go=!,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GOROOT%\bin:go.exe"
)
where /q "%GOBIN%:goimports.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,3,*" %%i in ('call "%GOROOT%\bin\go.exe" version -m "%GOBIN%\goimports.exe" ^| findstr mod.^*tools') do (
        set "__VERSIONS_LINE2=%__VERSIONS_LINE2% goimports %%k,"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%GOBIN%:goimports.exe"
)
where /q "%MSVS_HOME%\MSBuild\Current\Bin\Roslyn:csc.exe"
if %ERRORLEVEL%==0 (
    for /f "delims=- tokens=1,*" %%i in ('call "%MSVS_HOME%\MSBuild\Current\Bin\Roslyn\csc.exe" -version') do (
        set "__VERSIONS_LINE3=%__VERSIONS_LINE3% csc %%i,"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%MSVS_HOME%\MSBuild\Current\Bin\Roslyn:csc.exe"
)
where /q "%GIT_HOME%\bin:git.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1,2,*" %%i in ('"%GIT_HOME%\bin\git.exe" --version') do (
        for /f "delims=. tokens=1,2,3,*" %%a in ("%%k") do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% git %%a.%%b.%%c,"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:git.exe"
)
where /q "%GIT_HOME%\usr\bin:diff.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,*" %%i in ('"%GIT_HOME%\usr\bin\diff.exe" --version ^| findstr diff') do set "__VERSIONS_LINE3=%__VERSIONS_LINE3% diff %%l,"
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\usr\bin:diff.exe"
)
where /q "%GIT_HOME%\bin:bash.exe"
if %ERRORLEVEL%==0 (
    for /f "tokens=1-3,4,*" %%i in ('"%GIT_HOME%\bin\bash.exe" --version ^| findstr bash') do (
        set "__VERSION=%%l"
        setlocal enabledelayedexpansion
        set "__VERSIONS_LINE3=%__VERSIONS_LINE3% bash !__VERSION:-release=!"
    )
    set __WHERE_ARGS=%__WHERE_ARGS% "%GIT_HOME%\bin:bash.exe"
)
echo Tool versions:
echo   %__VERSIONS_LINE1%
echo   %__VERSIONS_LINE2%
echo   %__VERSIONS_LINE3%
if %__VERBOSE%==1 (
    echo Tool paths: 1>&2
    for /f "tokens=*" %%p in ('where %__WHERE_ARGS%') do (
        set "__LINE=%%p"
        setlocal enabledelayedexpansion
        echo    !__LINE:%USERPROFILE%=%%USERPROFILE%%! 1>&2
    )
    echo Environment variables: 1>&2
    if defined CARGO_HOME echo    "CARGO_HOME=!CARGO_HOME:%USERPROFILE%=%%USERPROFILE%%!" 1>&2
    if defined DAFNY_HOME echo    "DAFNY_HOME=%DAFNY_HOME%" 1>&2
    if defined GIT_HOME echo    "GIT_HOME=%GIT_HOME%" 1>&2
    if defined GOBIN echo    "GOBIN=!GOBIN:%USERPROFILE%=%%USERPROFILE%%!" 1>&2
    if defined GOPATH echo    "GOPATH=%GOPATH%" 1>&2
    if defined GOROOT echo    "GOROOT=%GOROOT%" 1>&2
    if defined JAVA_HOME echo    "JAVA_HOME=%JAVA_HOME%" 1>&2
    if defined MSVS_HOME echo    "MSVS_HOME=%MSVS_HOME%" 1>&2
    if defined VSCODE_HOME echo    "VSCODE_HOME=%VSCODE_HOME%" 1>&2
    echo Path associations: 1>&2
    for /f "delims=" %%i in ('subst') do (
        set "__LINE=%%i"
        setlocal enabledelayedexpansion
        echo    !__LINE:%USERPROFILE%=%%USERPROFILE%%! 1>&2
    )
)
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
where /q updatemds.bat
set __UPDATE_PATH=%ERRORLEVEL%
endlocal & (
    if %_EXITCODE%==0 (
        if not defined CARGO_HOME set "CARGO_HOME=%_CARGO_HOME%"
        if not defined DAFNY_HOME set "DAFNY_HOME=%_DAFNY_HOME%"
        if not defined GIT_HOME set "GIT_HOME=%_GIT_HOME%"
        if not defined GOBIN set "GOBIN=%_GOBIN%"
        if not defined GOPATH set "GOPATH=%_GOPATH%"
        if not defined GOROOT set "GOROOT=%_GOLANG_HOME%"
        if not defined JAVA_HOME set "JAVA_HOME=%_JAVA_HOME%"
        if not defined MSVS_HOME set "MSVS_HOME=%_MSVS_HOME%"
        if not defined VSCODE_HOME set "VSCODE_HOME=%_VSCODE_HOME%"
        @rem We prepend %_GIT_HOME%\bin to hide C:\Windows\System32\bash.exec
        if %__UPDATE_PATH%==1 set "PATH=%_GIT_HOME%\bin;%PATH%%_MSYS_PATH%%_GIT_PATH%%_VSCODE_PATH%;%~dp0bin"
        call :print_env %_VERBOSE%
        if not "%CD:~0,2%"=="%_DRIVE_NAME%" (
            if %_DEBUG%==1 echo %_DEBUG_LABEL% cd /d %_DRIVE_NAME% 1>&2
            cd /d %_DRIVE_NAME%
        )
        if %_BASH%==1 (
            @rem see https://conemu.github.io/en/GitForWindows.html
            if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_GIT_HOME%\usr\bin\bash.exe" --login 1>&2
            cmd.exe /c "%_GIT_HOME%\usr\bin\bash.exe --login"
        )
    )
    if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
    for /f "delims==" %%i in ('set ^| findstr /b "_"') do set %%i=
)
