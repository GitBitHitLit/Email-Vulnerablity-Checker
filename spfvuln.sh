#!/bin/bash

# Function to display the tool banner
function banner() {
    echo ""
    echo -e "  \033[0;31mThis Email Vulnerability Checker v.2.0\e Was Created By \e[1;32mBLACK-SCORP10 \e"
    echo ""
    echo -e "\e[1;34m               For Any Queries Join Me!!!\e[0m"
    echo -e "\e[1;32m           Telegram: https://t.me/BLACK-SCORP10 \e[0m"
    echo ""
    echo ""
}

# Function to check SPF and DMARC configurations and determine vulnerability status
function check_vulnerability {
    local domain=$1
    local spf_response=$(nslookup -type=TXT "$domain" | grep -Eo '\s*-all|\s*~all|\s*\+all|\s*\?all|\s*\redirect' || echo "no spf")

    local dmarc_response=$(nslookup -type=TXT "_dmarc.$domain" | grep -Eo '\bp=(reject|quarantine|none)\b|No answer' | head -n1 || echo "No answer")

    # Trim leading and trailing spaces from SPF and DMARC responses
    spf_response=$(echo "$spf_response" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    dmarc_response=$(echo "$dmarc_response" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^No answer$/No Answer/')

    # Convert "p=" to "no answer" for DMARC records
    if [[ "$dmarc_response" == "p=reject" ]]; then
        dmarc_response="reject"
    elif [[ "$dmarc_response" == "p=quarantine" ]]; then
        dmarc_response="quarantine"
    elif [[ "$dmarc_response" == "p=none" ]]; then
        dmarc_response="none"
    elif [[ "$dmarc_response" == "No Answer" ]]; then
        dmarc_response="No Answer"
    fi

    # Determine vulnerability status based on trimmed SPF and DMARC responses
    case "$spf_response $dmarc_response" in
        "-all reject")       vulnerability_status="Not Vulnerable"; color="\033[0;32m";;
        "-all quarantine")   vulnerability_status="Less Vulnerable"; color="\033[1;33m";;
        "-all none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "-all No Answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "~all reject")       vulnerability_status="Less Vulnerable"; color="\033[1;33m";;
        "~all quarantine")   vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "~all none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "~all No Answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "+all reject")       vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "+all quarantine")   vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "+all none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "+all No Answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "?all reject")       vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "?all quarantine")   vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "?all none")         vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "?all No Answer")    vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "no spf reject")     vulnerability_status="Vulnerable"; color="\033[0;31m";;
        "no spf quarantine") vulnerability_status="More Vulnerable"; color="\033[0;31m";;
        "no spf none")       vulnerability_status="Highly Vulnerable"; color="\033[0;31m";;
        "no spf No Answer")  vulnerability_status="Highly Vulnerable"; color="\033[0;31m";;
        *)                   vulnerability_status="Consider Redirect Mechanism"; color="\033[1;34m";;
    esac

    echo -e "\033[1;36mDomain: $domain - SPF: $spf_response - DMARC: $dmarc_response - Vulnerability Status: $color$vulnerability_status\033[0m"
}

# Main function to parse command line arguments and execute the vulnerability checker
function main {
    if [[ $# -eq 0 ]]; then
        banner
        echo "Usage: $0 [-h | --help] [-v] [-t <file> | -d <domain>] [-o <output.txt>]"
        exit 1
    fi

    local output_file=""
    local domains_file=""
    local single_domain=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                banner
                echo "Usage: $0 [-h | --help] [-v] [-t <file> | -d <domain>] [-o <output.txt>]"
                exit 0
                ;;
            -v)
                banner
                echo "Version: 2.0"
                exit 0
                ;;
            -t)
                shift
                domains_file=$1
                ;;
            -d)
                shift
                single_domain=$1
                ;;
            -o)
                shift
                output_file=$1
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
        shift
    done

    banner

    if [[ -n $domains_file ]]; then
        while IFS= read -r domain; do
            check_vulnerability "$domain"
        done < "$domains_file"
    elif [[ -n $single_domain ]]; then
        check_vulnerability "$single_domain"
    else
        echo "No domain specified. Use either -t for a domains file or -d for a single domain."
        exit 1
    fi

    if [[ -n $output_file ]]; then
        exec > "$output_file"
    fi
}

# Call the main function with command line arguments
main "$@"

# This code is made and owned by BLACK-SCORP10.
# Feel free to contact me at https://t.me/BLACK_SCORP10
