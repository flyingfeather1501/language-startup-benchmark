#!/bin/bash
# compiling functions
# should take in a source file and return (to stdout) an executable of some sort

compile:rust () {
    tmp=$(mktemp --tmpdir tmp-XXXX.rs)
    out=$(mktemp --tmpdir exe.rust.XXXX)
    cat "$1" > "$tmp"
    quiet rustc -o "$out" "$tmp"
    rm "$tmp"
    echo "$out"
}

compile:go () {
    # compile:go <source file> -> path
    tmp=$(mktemp --tmpdir tmp.go.XXXX.o)
    out=$(mktemp --tmpdir exe.go.XXXX)
    quiet go tool compile -o "$tmp" "$1"
    quiet go tool link -o "$out" "$tmp"
    rm "$tmp"
    echo "$out"
}

compile:gcc () {
    # compile:gcc <source file> -> path
    tmp=$(mktemp --tmpdir tmp.XXXX.c)
    out=$(mktemp --tmpdir exe.gcc.XXXX)
    cat "$1" > "$tmp" # to avoid .o files being left in pwd
    quiet gcc -o "$out" "$tmp"
    rm "$tmp"
    echo "$out"
}

compile:vala () {
    tmp=$(mktemp --tmpdir tmp.XXXX.vala)
    out=$(mktemp --tmpdir exe.vala.XXXX)
    cat "$1" > "$tmp"
    quiet valac -o "$out" "$tmp"
    rm "$tmp"
    echo "$out"
}

compile:haskell () {
    tmp=$(mktemp --tmpdir tmp.XXXX.hs)
    out=$(mktemp --tmpdir exe.haskell.XXXX)
    cat "$1" > "$tmp"
    quiet docker run --rm \
        -v "$tmp":"$tmp"\
        -v "$out":"$out"\
        haskell \
        ghc -o "$out" "$tmp"
    rm "$tmp"
    echo "$out"
}

compile:java () {
    tmpdir=$(mktemp -d --tmpdir)
    tmp="$tmpdir"/hello.java
    cat "$1" > "$tmp"
    quiet javac "$tmp" # -> XXXX.class
    echo "$tmpdir"
}

compile:nim () {
    src=$(mktemp --tmpdir XXXX.nim)
    out=$(echo "$src" | sed 's/\.nim//')
    cat "$1" > "$src"
    quiet nim compile --verbosity:0 "$src"
    echo "$out"
    rm "$src"
}
