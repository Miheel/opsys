#!/bin/bash
#Mikael Leuf
#2020-02-28

LANG=se_SV.UTF-8
TABLE='BEGIN{printf("%-3s\t%-10s\t%-5s\t%-3s\t%-3s\t%-3s\n","ID","Namn","Vikt","L","B","H")}{printf("%-3d\t%-10s\t%-5d\t%-3d\t%-3d\t%-3d\n",$1,$2,$3,$4,$5,$6)}'
FIELD_SEP=","
FILE=

function backup_file()
{
    cp $FILE $FILE.backup
    echo "Backup generated"
}

function print_file()
{
    awk -F$FIELD_SEP $TABLE $FILE
}

function sort_file()
{
    SORT_ARG=
    case $SORT_OPT in
        "i")
            SORT_ARG="-g";;
        "n")
            SORT_ARG="-k2";;
        "v")
            SORT_ARG="-gk3";;
        "l")
            SORT_ARG="-gk4";;
        "b")
            SORT_ARG="-gk5";;
        "h")
            SORT_ARG="-gk6";;
        *)
            echo "Invalid argument for sort";;
    esac
    
    sort $SORT_ARG -t$FIELD_SEP $FILE | awk -F$FIELD_SEP $TABLE
}

function help_text()
{
    echo "Usage: logistics  FILE [-b|-p|-s {i|n|v|l|b|h}]
	Used  for  logistics  management  with  FILE as  underlying data.
	-b       generate  backup  copy of data  contents
	-p       print  data  contents  and  exit
	-s       sort by  additional  argument: id (i),
				name (n), weight (v), length (l)
				width (b), height (h), print  data
				contents  and  exit
    --help   display  this  help  and  exit"
}

function inter_help()
{
    echo -n "Help
    b : generate  backup  copy of data  contents
    p : print  data  contents
    s : sort sort data contents (aditional args {i|n|v|l|b|h})
    h : print help text
    q : quit
    chose an option: "
}

function check_file()
{
    if [ ! -f "$FILE" ]; then
        echo "No file set"
        exit 1
    fi
}

function no_file()
{
    echo "File was not set."
}

if [ -f "$1" ] && [ -z "$2" ]; then
    FILE="$1"
    while [ "$OPTION" != "q" ]; do
        inter_help
        read OPTION
        
        case $OPTION in
            "h")
                clear
            ;;
            "b")
                if [ ! -f "$FILE" ]; then
                    no_file
                else
                    backup_file
                fi
            ;;
            "p")
                if [ ! -f "$FILE" ]; then
                    no_file
                else
                    print_file
                fi
            ;;
            "s")
                if [ ! -f "$FILE" ]; then
                    no_file
                else
                    echo -n "Chose an sorting option: "
                    read SORT_OPT
                    sort_file
                fi
            ;;
            "q")
                exit 1
            ;;
            *)
                echo "Unknown action"
            ;;
        esac
    done
fi

if [ "$1" == "-h" ]; then
    help_text
    exit 1
fi

FILE="$1"
check_file

case $2 in
    "-b")
        backup_file
    ;;
    "-p")
        print_file
    ;;
    "-s")
        if [ ! -z "$3" ]; then
            SORT_OPT="$3"
            sort_file
        else 
            echo "Sort needs additional arguments"
            help_text
        fi
    ;;
    *)
        help_text
    ;;
esac
