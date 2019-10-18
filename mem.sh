#!/usr/bin/env bash

## Function to show error and exit
errexit()
{
    echo "process not found.";
    exit 1;
}

## Check number of arguments passed
if (( "$#" < 1 || "$#" > 2 )); then
    echo "usage: memusage pname/pid [secdelay]";
    exit 1;
fi

## Get the PID
if [ "$1" -eq "$1" ] 2>/dev/null; then
    pidno="$1"
else
    pidarr=( `pgrep $1` )
    len=${#pidarr[@]}

    if (( "$len" == 0 )); then
        errexit;
    elif (( "$len" != 1 )); then
        echo "found PIDs: "${pidarr[@]}""
        echo -n "PID to log ('Enter' for latest): ";
        read pidno;
        if [ -z "$pidno" ]; then
            pidno="${pidarr["$len" - 1]}"
            echo "choosing the latest one: $pidno"
        fi

        echo ""
    else
        pidno="${pidarr[0]}"
    fi
fi

echo -e "logging PID: $pidno\n"

## Print header
echo -e "Size\tResid.\tShared\tData\t%"

while [ 1 ]; do
    ## If the process is running, print the memory usage
    if [ -e /proc/$pidno/statm ]; then
        ## Get the memory info

        m=`awk '{OFS="\t";print $1,$2,$3,$6}' /proc/$pidno/statm`

        ## Ghi vào file 
        echo "$1  $2  $3  $6" >> txt

        ## Get the memory percentage
        perc=`top -bd .10 -p $pidno -n 1  | grep $pidno | gawk '{print \$10}'`

        ## print the results
        echo -e "$m\t$perc";

        ## Sleep, if opted
        if [ ! -z "$2" ]; then
            sleep "$2"
        fi
    ## If the process does not exist
    else
        errexit;
    fi
done