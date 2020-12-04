#!/bin/bash

total=0
acc=""

validate() {
    acc="$acc "
    okay=1
    if [[ ! $acc =~ .*byr:(....)[[:space:]].* ]]; then
        okay=0
    fi
    if [[ (${BASH_REMATCH[1]} -lt 1920) || (${BASH_REMATCH[1]} -gt 2002) ]]; then
        okay=0
    fi
    if [[ ! $acc =~ .*iyr:(....)[[:space:]].* ]]; then
        okay=0
    fi
    if [[ (${BASH_REMATCH[1]} -lt 2010) || (${BASH_REMATCH[1]} -gt 2020) ]]; then
        okay=0
    fi
    if [[ ! $acc =~ .*eyr:(....)[[:space:]].* ]]; then
        okay=0
    fi
    if [[ (${BASH_REMATCH[1]} -lt 2020) || (${BASH_REMATCH[1]} -gt 2030) ]]; then
        okay=0
    fi
    if [[ ! $acc =~ .*hgt:([0-9]+)(cm|in)[[:space:]].* ]]; then
        okay=0
    fi
    case "${BASH_REMATCH[2]}" in
        in)
            if [[ (${BASH_REMATCH[1]} -lt 59) || (${BASH_REMATCH[1]} -gt 76) ]]; then
                okay=0
            fi
            ;;
        cm)
            if [[ (${BASH_REMATCH[1]} -lt 150) || (${BASH_REMATCH[1]} -gt 193) ]]; then
                okay=0
            fi
            ;;
        *)
            okay=0
            ;;
    esac
    if [[ ! $acc =~ .*hcl:#[0-9a-f]{6}[[:space:]].* ]]; then
        okay=0
    fi
    if [[ ! $acc =~ .*ecl:(amb|blu|brn|gry|grn|hzl|oth)[[:space:]].* ]]; then
        okay=0
    fi
    if [[ ! $acc =~ .*pid:[0-9]{9}[[:space:]].* ]]; then
        okay=0
    fi
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
