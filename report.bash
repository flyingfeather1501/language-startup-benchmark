#!/bin/bash
# report functions
# this script can be used on its own as the report_time function
report_success () {
    # report_success <title> <output> <time>
    cat <<JSON
{"status":"success","report":{"title":"$1","output":"$2","time":$3,"unit":"second"}}
JSON
}

report_status () {
    cat <<JSON
{"status": "$1"}
JSON
}

# time the command and format the result
report_time () {
    # report_time <title> <command> <args> ...
    TIMEFORMAT="%3R"
    title="$1"; shift 1
    tmp_time=$(mktemp)
    tmp_cmd_output=$(mktemp)

    # { time stuff }: output of stuff -> stdout, time -> stderr
    if ! { time "$@" 2>/dev/null; } > "$tmp_cmd_output" 2> "$tmp_time"
    then
        error "$* failed"
        return
    fi

    time_seconds=$(cat "$tmp_time")
    output=$(cat "$tmp_cmd_output")
    report_success "$title" "$output" "$time_seconds"
    rm "$tmp_time" "$tmp_cmd_output"
}

error () {
    echo '{"status":"failed",'\
          '"message": "'"$*"'"}'
}

standalone () {
    [ "$0" == "report.bash" ] && return 0
    return 1 # would not be run had above succeeded
}

if standalone; then
    report_time "$@"
    exit
fi
