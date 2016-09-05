#!/bin/bash
# Define custom colors
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[35m'
LGREEN='\033[92m'
NC='\033[0m'

# Define font styles
bold='\033[1m'
normal='\033[0m'

# Define file to be checked
file=$1
EXT=${file: -4}

# Check if the argument was not passed
if [[ ! -n "$file" ]]; then
    echo -e "${RED}${bold}ERROR:${normal}${YELLOW} I'M EXPECTING AN .INI FILE, OTHERWISE NOTHING TO DO HERE. AUREVOIRE!${NC}\n"
    exit 1
fi

# Check if the file does not exists in PWD
if [[ ! -f "$file" ]]; then
    echo -e "${RED}${bold}ERROR:${normal} ${YELLOW}I CAN'T FIND THE FILE ${BLUE}$file.\n${YELLOW}ARE YOU SURE YOU ARE IN THE RIGHT DIRECTORY?${NC}\n"
    exit 1
fi

# Check if an .ini file was not provided
if [[ "$EXT" != ".ini" ]]; then
    echo -e "${RED}${bold}ERROR:${normal}${YELLOW} WHAT ARE YOU GIVING ME ${RED}$EXT${YELLOW} FILE FOR?\nYOU KNOW I CAN PLAY WELL ONLY WITH ${RED}.INI ${YELLOW}FILES :)!${NC}\n"
    exit 1
fi

# determine OS
platform=`uname`
echo -e "You are running ${RED}$platform OS ${NC}"
# implement logic for awk/nawk based in the OS
if [[ "$platform" == 'Linux' ]]; then
    a=awk
elif [[ "$platform" == 'SunOS' ]]; then
    a=nawk
elif [[ "$platform" == 'Darwin' ]]; then
    echo -e "${PURPLE}Fanci me a Mac ... ${bold}BigMac${normal}${PURPLE} that is!${NC}"
    a=awk
else
    echo -e "${RED}${bold}DUDE!!!${normal}${GREEN} What OS are you running? You know I'm good with ${RED}${bold} Linux ${normal}${GREEN}and ${RED}${bold}SunOS${normal}${GREEN} right?\n${LGREEN}Come back when you use a normal machine like anyone else ;)${NC}\n"
    exit 1
fi

### FUNCTION grabAttCond() ###
##############################
# searches in the INI file passed as argumnet for attachement-conditions
# if any found, searches for each conditions if attached to other plugins
function checkAttCond(){
    echo -e "${PURPLE}${bold}==========================================${normal}${NC}"
    echo -e "${PURPLE}${bold}=     Checking attachment-conditions     =${normal}${NC}"
    echo -e "${PURPLE}${bold}==========================================${normal}${NC}\n"
    # build conditions array
    read -a conditions <<< $($a -F "then" '/[attachment-condition]/ {print $2}' $file | sed '/^\s*$/d')
    if [[ ${#conditions[@]} -gt 1 ]]; then
        echo -e "There are ${RED}${bold}${#conditions[@]}${normal}${NC} attachment-condition to ${BLUE}${bold}$file${normal}${NC}\n"
    else
        echo -e "There is ${RED}${bold}${#conditions[@]}${normal}${NC} attchement-condition to ${BLUE}${bold}$file${normal}${NC}\n"
    fi

    # check if any of the conditions found are present in any other plugin
    for i in "${conditions[@]}"
    do
        usage=$(grep ${i} *.ini | wc -l)
        usage=$((usage-1))
        if  [[ $usage -gt 0 ]]; then
            echo -e "Condition ${RED}${i}${NC} is used in other \n ${YELLOW}${bold}$usage${normal}${NC} file(s)"
            echo -e "\n"
        else
            echo -e "Condition ${RED}${i}${NC} is NOT used in other files.\n ${LGREEN}You can safely remove it!${NC}"
            echo -e "\n"
        fi
    done
}

function checkRouting(){
    echo -e "${PURPLE}${bold}===========================${normal}${NC}"
    echo -e "${PURPLE}${bold}=     Checking routing    =${normal}${NC}"
    echo -e "${PURPLE}${bold}===========================${normal}${NC}"
    echo -e "${YELLOW}HOLD ON BO\$$. THIS FUNCTIONALITY IS NOT YET IMPLEMENTED${NC}\n\n"
}

function checkCFBUsage(){
    echo -e "${PURPLE}${bold}================================${normal}${NC}"
    echo -e "${PURPLE}${bold}=     Checking CFB usage       =${normal}${NC}"
    echo -e "${PURPLE}${bold}================================${normal}${NC}\n"
    # check if cfb is mentioned in INI
    cfb=$(less $file | grep cfb | $a -F "=" '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
    if [ -z "$cfb" ]; then # cfb not mentioned in the ini file
        echo -e "I DIDN'T FIND ANY CFB MENTIONED IN THE ${RED}$file${NC} FILE"
        # generate file name based on .ini file
        ext='.cfb'
        cfb=${file%.*}$ext
        echo -e "I WILL ASSUME ${RED}${bold}$cfb${normal}${NC}.\nLET ME CHECK IF THE FILE EXIST ..."

        if [[ ! -f "$cfb" ]]; then
            echo -e "${RED}${bold}ERROR:${normal}${YELLOW}THIS IS EITHER A JAVA PLUGIN, OR SOMETHING IS WRONG HERE\nBECAUSE I CAN'T FIND ${RED}${bold}$cfb!${normal}\n${YELLOW}MAKE SURE TO SELECT A ${LGREEN}FIX CMS${YELLOW} PLUGIN!${NC}\n"
            displayMenu
        else
            read -a used <<< $(grep $cfb *.ini | $a -F ":" '{print $1}')
            if  [[ ${#used[@]} -gt 1 ]]; then
                echo -e "CFB file ${RED}$cfb${NC} is used in other ${YELLOW}${bold}$((${#used[@]}-1))${normal}${NC} plugin(s)"
                # print out the files except the one checked
                for i in "${used[@]}"
                do
                    if [[ "${i}" != "$file" ]]; then
                        echo -e "${YELLOW}${bold}$i${normal}${NC}"
                    fi
                done
                echo -e "\n"
            else
                echo -e "CFB file ${RED}$cfb${NC} is NOT used in other files.\n${LGREEN}You can safely remove it!${NC}"
                echo -e "\n"
            fi
        fi
    else
        echo -e "I FOUND ${RED}${bold}$cfb${normal}${NC}"
        # check what other plugin(s) use this CFB file
        read -a used <<< $(grep $cfb *.ini | $a -F ":" '{print $1}')
        if  [[ ${#used[@]} -gt 1 ]]; then
            echo -e "CFB file ${RED}$cfb${NC} is used in other ${YELLOW}${bold}$((${#used[@]}-1))${normal}${NC} plugin(s)"
            # print out the files except the one checked
            for i in "${used[@]}"
            do
                if [[ "${i}" != "$file" ]]; then
                    echo -e "${YELLOW}${bold}$i${normal}${NC}"
                fi
            done
            echo -e "\n"
        else
            echo -e "CFB file ${RED}$cfb${NC} is NOT used in other files.\n${LGREEN}You can safely remove it!${NC}"
            echo -e "\n"
        fi
    fi
}

function displayMenu(){
    while true
    do
        echo -e "${PURPLE}${bold}===========================================${normal}${NC}"
        echo -e "${PURPLE}${bold}#                                         #${normal}${NC}"
        echo -e "${PURPLE}${bold}#        Wellcome to VeryFIX Menu ...     #${normal}${NC}"
        echo -e "${PURPLE}${bold}#                                         #${normal}${NC}"
        echo -e "${PURPLE}${bold}===========================================${normal}${NC}\n"
        echo -e "Enter ${RED}${bold}1${normal}${NC} to check ${YELLOW}Attachment-condition${NC}"
        echo -e "Enter ${RED}${bold}2${normal}${NC} to check ${YELLOW}Routing${NC}"
        echo -e "Enter ${RED}${bold}3${normal}${NC} to check ${YELLOW}CFB usage${NC}"
        echo -e "Enter ${RED}${bold}q${normal}${NC} to ${YELLOW}Quit${NC}"
        echo -e "\n"
        echo -e "Select your option: \c"
        read sel
        
        case "$sel" in
            1) checkAttCond ;;
            2) checkRouting ;;
            3) checkCFBUsage ;;
            q) exit ;;
        esac
    done
}

displayMenu