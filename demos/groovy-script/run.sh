#!/usr/bin/env bash

if [[ ! -f ./jobs ]]; then
    ./compile.sh
fi

./jobs -Djava.library.path=$JAVA_HOME/jre/lib/amd64
