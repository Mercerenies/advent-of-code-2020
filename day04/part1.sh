#!/bin/bash

fields="byr iyr eyr hgt hcl ecl pid"

total=0
acc=""

validate() {
    okay=1
    for field in $fields; do
        if [[ ! $acc == *$field* ]]; then
            okay=0
        fi
    done
    total=$((total + okay))
}

while read -r line; do
    acc="$acc $line"
    if [ -z "$line" ]; then
        validate
        acc=""
    fi
done <input.txt
validate

echo $total
