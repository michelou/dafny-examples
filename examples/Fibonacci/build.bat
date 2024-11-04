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

for %%i in (%_COMMANDS%) do (
    call :%%i
    if not !_EXITCODE!==0 goto end
)
goto end

@rem #########################################################################
@rem ## Subroutines

@rem output parameters: _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
@rem                    _SOURCE_DIR, _TARGET_DIR
:env
set _BASENAME=%~n0
set "_ROOT_DIR=%~dp0"

call :env_colors
set _DEBUG_LABEL=%_NORMAL_BG_CYAN%[%_BASENAME%]%_RESET%
set _ERROR_LABEL=%_STRONG_FG_RED%Error%_RESET%:
set _WARNING_LABEL=%_STRONG_FG_YELLOW%Warning%_RESET%:

set "_SOURCE_DIR=%_ROOT_DIR%src"
set "_TARGET_DIR=%_ROOT_DIR%target"

set "_APP_NAME=Fib"
set "_EXE_FILE=%_TARGET_DIR%\%_APP_NAME%.exe"

if not exist "%DAFNY_HOME%\dafny.exe" (
    echo %_ERROR_LABEL% Dafny installation not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_DAFNY_CMD=%DAFNY_HOME%\dafny.exe"
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

@rem we define _RESET to avoid crazy console output with type command
set _BOLD=[1m
set _UNDERSCORE=[4m
set _INVERSE=[7m
set _RESET=[0m
goto :eof

@rem input parameter: %*
:args
set _COMMANDS=
@rem option --target takes one of 'cs' (C#), 'js' (JavaScript), 'go' (Go),
@rem 'java' (Java), 'py' (Python), 'cpp' (C++), 'lib' (Dafny Library (.doo)),
@rem 'rs' (Rust), 'dfy' (ResolvedDesugaredExecutableDafny)
set _TARGET=native
set _VERBOSE=0
set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _COMMANDS=help
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    @rem option
    if "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if "%__ARG%"=="-target:go" ( set _TARGET=go
    ) else if "%__ARG%"=="-target:java" ( set _TARGET=java
    ) else if "%__ARG%"=="-target:rs" ( set _TARGET=rs
    ) else if "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
) else (
    @rem subcommand
    if "%__ARG%"=="clean" ( set _COMMANDS=!_COMMANDS! clean
    ) else if "%__ARG%"=="compile" ( set _COMMANDS=!_COMMANDS! compile
    ) else if "%__ARG%"=="help" ( set _COMMANDS=help
    ) else if "%__ARG%"=="run" ( set _COMMANDS=!_COMMANDS! compile run
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand "%__ARG%" 1>&2
        set _EXITCODE=1
        goto args_done
    )
    set /a __N+=1
)
shift
goto args_loop
:args_done
set _STDERR_REDIRECT=2^>NUL
if %_DEBUG%==1 set _STDERR_REDIRECT=

if %_TARGET%==native ( set __TARGET_EXT=.exe
) else if %_TARGET%==go ( set __TARGET_EXT=.exe
) else if %_TARGET%==java ( set __TARGET_EXT=.jar
) else if %_TARGET%==rs ( set __TARGET_EXT=.exe
) else (
    echo %_ERROR_LABEL% Unknown target "%_TARGET%" 1>&2
    set _EXITCODE=1
    goto :eof
)
set "_TARGET_FILE=%_TARGET_DIR%\%_APP_NAME%%__TARGET_EXT%"

if %_DEBUG%==1 (
    echo %_DEBUG_LABEL% Options    : _TARGET=%_TARGET% _VERBOSE=%_VERBOSE% 1>&2
    echo %_DEBUG_LABEL% Subcommands: %_COMMANDS% 1>&2
    echo %_DEBUG_LABEL% Variables  : "DAFNY_HOME=%DAFNY_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "GIT_HOME=%GIT_HOME%" 1>&2
    echo %_DEBUG_LABEL% Variables  : "JAVA_HOME=%JAVA_HOME%" 1>&2
)
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
echo     %__BEG_O%-debug%__END%      print commands executed by this script
echo     %__BEG_O%-verbose%__END%    print progress messages
echo.
echo   %__BEG_P%Subcommands:%__END%
echo     %__BEG_O%clean%__END%       delete generated files
echo     %__BEG_O%compile%__END%     compile Dafny source files
echo     %__BEG_O%help%__END%        print this help message
echo     %__BEG_O%run%__END%         execute main program "%__BEG_N%!_TARGET_FILE:%_ROOT_DIR%=!%__END%"
goto :eof

@rem #########################################################################
@rem ## Cleanups

:clean
call :rmdir "%_TARGET_DIR%"
goto :eof

@rem input parameter: %1=directory path
:rmdir
set "__DIR=%~1"
if not exist "%__DIR%\" goto :eof
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% rmdir /s /q "%__DIR%" 1>&2
) else if %_VERBOSE%==1 ( echo Delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
)
rmdir /s /q "%__DIR%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to delete directory "!__DIR:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:compile
if not exist "%_TARGET_DIR%" mkdir "%_TARGET_DIR%"

set __SOURCE_FILES=
set __N=0
for /f "delims=" %%f in ('dir /b /s "%_SOURCE_DIR%\*.dfy" 2^>NUL') do (
    set __SOURCE_FILES=!__SOURCE_FILES! "%%f"
    set /a __N+=1
)
if %__N%==0 (
    echo %_WARNING_LABEL% No Dafny source file found 1>&2
    goto :eof
) else if %__N%==1 ( set __N_FILES=%__N% Dafny source file
) else ( set __N_FILES=%__N% Dafny source files
)

set __BUILD_OPTS=--output "%_TARGET_FILE%"
if not %_TARGET%==native set __BUILD_OPTS=--target %_TARGET% %__BUILD_OPTS%

set "__PATH=%PATH%"
if %_TARGET%==go ( set "PATH=%GOROOT%\bin;%GOBIN%;%__PATH%"
) else if %_TARGET%==java set "PATH=%JAVA_HOME%\bin;%__PATH%"
) else if %_TARGET%==rs ( set "PATH=%USERPROFILE%\.cargo\bin;%__PATH%"
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% "!_DAFNY_CMD:%DAFNY_HOME%=%%DAFNY_HOME%%!" build %__BUILD_OPTS% %__SOURCE_FILES% 1>&2
) else if %_VERBOSE%==1 ( echo Build Dafny program "!_TARGET_FILE:%_ROOT_DIR%=!" 1>&2
)
call "%_DAFNY_CMD%" build %__BUILD_OPTS% %__SOURCE_FILES%
if not %ERRORLEVEL%==0 (
    if not %_TARGET%==native set "PATH=%__PATH%"
    echo %_ERROR_LABEL% Failed to build Dafny program "!_TARGET_FILE:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
if not %_TARGET%==native set "PATH=%__PATH%"
goto :eof

:run
if not exist "%_TARGET_FILE%" (
    echo %_ERROR_LABEL% Dafny program "!_TARGET_FILE:%_ROOT_DIR%=!" not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __RUN_OPTS=

if %_TARGET%==java (
    set __EXECUTOR="%JAVA_HOME%\bin\java.exe"
    set __EXECUTOR_OPTS=-jar
) else (
    set __EXECUTOR=
    set __EXECUTOR_OPTS=
)
if %_DEBUG%==1 ( echo %_DEBUG_LABEL% !__EXECUTOR:%JAVA_HOME%=%%JAVA_HOME%%! %__EXECUTOR_OPTS% "%_TARGET_FILE%" 1>&2
) else if %_VERBOSE%==1 ( echo Execute Dafny program "!_TARGET_FILE:%_ROOT_DIR%=!" 1>&2
)
call %__EXECUTOR% %__EXECUTOR_OPTS% "%_TARGET_FILE%"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to execute Dafny program "!_TARGET_FILE:%_ROOT_DIR%=!" 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:end
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
