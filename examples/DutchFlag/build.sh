#!/usr/bin/env bash
#
# Copyright (c) 2018-2024 Stéphane Micheloud
#
# Licensed under the MIT License.
#

##############################################################################
## Subroutines

getHome() {
    local source="${BASH_SOURCE[0]}"
    while [[ -h "$source" ]]; do
        local linked="$(readlink "$source")"
        local dir="$( cd -P $(dirname "$source") && cd -P $(dirname "$linked") && pwd )"
        source="$dir/$(basename "$linked")"
    done
    ( cd -P "$(dirname "$source")" && pwd )
}

debug() {
    local DEBUG_LABEL="[46m[DEBUG][0m"
    [[ $DEBUG -eq 1 ]] && echo "$DEBUG_LABEL $1" 1>&2
}

warning() {
    local WARNING_LABEL="[46m[WARNING][0m"
    echo "$WARNING_LABEL $1" 1>&2
}

error() {
    local ERROR_LABEL="[91mError:[0m"
    echo "$ERROR_LABEL $1" 1>&2
}

# use variables EXITCODE, TIMER_START
cleanup() {
    [[ $1 =~ ^[0-1]$ ]] && EXITCODE=$1

    if [[ $TIMER -eq 1 ]]; then
        local TIMER_END=$(date +'%s')
        local duration=$((TIMER_END - TIMER_START))
        echo "Total execution time: $(date -d @$duration +'%H:%M:%S')" 1>&2
    fi
    debug "EXITCODE=$EXITCODE"
    exit $EXITCODE
}

args() {
    [[ $# -eq 0 ]] && HELP=true && return 1

    for arg in "$@"; do
        case "$arg" in
        ## options
        -debug)    DEBUG=1 ;;
        -help)     HELP=1 ;;
        -verbose)  VERBOSE=1 ;;
        -*)
            error "Unknown option \"$arg\""
            EXITCODE=1 && return 0
            ;;
        ## subcommands
        clean)     CLEAN=1 ;;
        compile)   COMPILE=1 ;;
        help)      HELP=1 ;;
        run)       COMPILE=1 && RUN=1 ;;
        *)
            error "Unknown subcommand \"$arg\""
            EXITCODE=1 && return 0
            ;;
        esac
    done
    debug "Options    : TIMER=$TIMER VERBOSE=$VERBOSE"
    debug "Subcommands: CLEAN=$CLEAN COMPILE=$COMPILE DOC=$DOC HELP=$HELP LINT=$LINT RUN=$RUN"
    debug "Variables  : DAFNY_HOME=$DAFNY_HOME"
    debug "Variables  : GIT_HOME=$GIT_HOME"
    # See http://www.cyberciti.biz/faq/linux-unix-formatting-dates-for-display/
    [[ $TIMER -eq 1 ]] && TIMER_START=$(date +"%s")
}

help() {
    cat << EOS
Usage: $BASENAME { <option> | <subcommand> }

  Options:
    -debug       print commands executed by this script
    -verbose     print progress messages

  Subcommands:
    clean        delete generated files
    compile      compile Dafny source files
    help         print this help message
    run          execute the generated program "${TARGET_FILE/$ROOT_DIR\//}"
EOS
}

clean() {
    if [[ -d "$TARGET_DIR" ]]; then
        if [[ $DEBUG -eq 1 ]]; then
            debug "Delete directory \"$TARGET_DIR\""
        elif [[$VERBOSE -eq 1 ]]; then
            echo "Delete directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
        fi
        rm -rf "$TARGET_DIR"
        [[ $? -eq 0 ]] || ( EXITCODE=1 && return 0 )
    fi
}

compile() {
    [[ -d "$TARGET_DIR" ]] || mkdir -p "$TARGET_DIR"

    local is_required="$(action_required "$TARGET_FILE" "$SOURCE_DIR/main/dart/" "*.dart")"
    [[ $is_required -eq 0 ]] && return 1

    local source_files=
    local n=0
    for f in $(find "$SOURCE_DIR/main/dart/" -type f -name "*.dart" 2>/dev/null); do
        source_files="$source_files\"$f\" "
        n=$((n + 1))
    done
    if [[ $n -eq 0 ]]; then
        warning "No Dafny source file found"
        return 1
    fi
    local s=; [[ $n -gt 1 ]] && s="s"
    local n_files="$n Dafny source file$s"
    local dafny_opts="--output \"$TARGET_FILE\""
    [[ $DEBUG -eq 1 ]] && dafny_opts="--verbose $dafny_opts"
    if [[ $DEBUG -eq 1 ]]; then
        debug "$DART_CMD build $dafny_opts $source_files"
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Compile $n_files to directory \"${TARGET_DIR/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "\"$DART_CMD\" builf $dafny_opts $source_files"
    if [[ $? -ne 0 ]]; then
        error "Failed to compile $n_files to directory \"${TARGET_DIR/$ROOT_DIR\//}\""
        cleanup 1
    fi  
}

action_required() {
    local timestamp_file=$1
    local search_path=$2
    local search_pattern=$3
    local latest=
    for f in $(find $search_path -name $search_pattern 2>/dev/null); do
        [[ $f -nt $latest ]] && latest=$f
    done
    if [[ -z "$latest" ]]; then
        ## Do not compile if no source file
        echo 0
    elif [[ ! -f "$timestamp_file" ]]; then
        ## Do compile if timestamp file doesn't exist
        echo 1
    else
        ## Do compile if timestamp file is older than most recent source file
        local timestamp=$(stat -c %Y $timestamp_file)
        [[ $timestamp_file -nt $latest ]] && echo 1 || echo 0
    fi
}

mixed_path() {
    if [[ -x "$CYGPATH_CMD" ]]; then
        $CYGPATH_CMD -am $1
    elif [[ $(($mingw + $msys)) -gt 0 ]]; then
        echo $1 | sed 's|/|\\\\|g'
    else
        echo $1
    fi
}

run() {
    if [[ ! -f "$TARGET_FILE" ]]; then
        error "Main program \"${MAIN_CLASS/$ROOT_DIR\//}\" not found"
        cleanup 1
    fi
    if [[ $DEBUG -eq 1 ]]; then
        debug "Execute program \"$TARGET_FILE\""
    elif [[ $VERBOSE -eq 1 ]]; then
        echo "Execute program \"${TARGET_FILE/$ROOT_DIR\//}\"" 1>&2
    fi
    eval "$TARGET_FILE"
    if [[ $? -ne 0 ]]; then
        error "Failed to execute program \"${TARGET_FILE/$ROOT_DIR\//}\""
        cleanup 1
    fi
}

run_tests() {
    echo "tests"
}

##############################################################################
## Environment setup

BASENAME=$(basename "${BASH_SOURCE[0]}")

EXITCODE=0

ROOT_DIR="$(getHome)"

SOURCE_DIR="$ROOT_DIR/src"
TARGET_DIR="$ROOT_DIR/target"
TARGET_DOCS_DIR="$TARGET_DIR/docs"

## We refrain from using `true` and `false` which are Bash commands
## (see https://man7.org/linux/man-pages/man1/false.1.html)
CLEAN=0
COMPILE=0
DEBUG=0
HELP=0
RUN=0
TIMER=0
VERBOSE=0

COLOR_START="[32m"
COLOR_END="[0m"

cygwin=0
mingw=0
msys=0
darwin=0
case "$(uname -s)" in
    CYGWIN*) cygwin=1 ;;
    MINGW*)  mingw=1 ;;
    MSYS*)   msys=1 ;;
    Darwin*) darwin=1
esac
unset CYGPATH_CMD
PSEP=":"
if [[ $(($cygwin + $mingw + $msys)) -gt 0 ]]; then
    CYGPATH_CMD="$(which cygpath 2>/dev/null)"
    PSEP=";"
    [[ -n "$DAFNY_HOME" ]] && DAFNY_HOME="$(mixed_path $DAFNY_HOME)"
    [[ -n "$GIT_HOME" ]] && GIT_HOME="$(mixed_path $GIT_HOME)"
    DIFF_CMD="$GIT_HOME/usr/bin/diff.exe"
else
    DIFF_CMD="$(which diff)"
fi
if [[ ! -x "$DAFNY_HOME/bin/dart" ]]; then
    error "Dart installation not found"
    cleanup 1
fi
DAFNY_CMD="$DAFNY_HOME/Dafny.exe"

PROJECT_NAME="$(basename $ROOT_DIR)"
PROJECT_URL="github.com/$USER/dart-examples"
PROJECT_VERSION="1.0-SNAPSHOT"

APP_NAME="Fibonacci"
APP_VERSION="0.1.0"

TARGET_FILE="$TARGET_DIR/$APP_NAME-$APP_VERSION.exe"

args "$@"
[[ $EXITCODE -eq 0 ]] || cleanup 1

##############################################################################
## Main

[[ $HELP -eq 1 ]] && help && cleanup

if [[ $CLEAN -eq 1 ]]; then
    clean || cleanup 1
fi
if [[ $COMPILE -eq 1 ]]; then
    compile || cleanup 1
fi
if [[ $RUN -eq 1 ]]; then
    run || cleanup 1
fi
if [[ $TEST -eq 1 ]]; then
    run_tests || cleanup 1
fi
cleanup
