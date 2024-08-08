#!/usr/bin/env bash

SRC_FILE=$1
TARGET_FILE=$2

SRC_FILE=${SRC_FILE:-outputs/tests/coverage.txt}
TARGET_FILE=${TARGET_FILE:-outputs/tests/coverage.xml}

# Generate the main test report
go test ./... | go-junit-report > outputs/tests/report.xml

# Create the coverage txt file
go test ./... -v -coverprofile=${SRC_FILE}

echo "Source file: $SRC_FILE"
echo "Target file: $TARGET_FILE"

if [ ! -f $SRC_FILE ] && [ ! -f $TARGET_FILE ]
then
    echo "Both SRC_FILE and TARGET_FILE must exist"
else
    gocover-cobertura < $SRC_FILE > $TARGET_FILE
fi
