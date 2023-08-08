#!/bin/bash
shopt -s expand_aliases
Font_Black="\033[30m"
Font_Red="\033[31m"
Font_Green="\033[32m"
Font_Yellow="\033[33m"
Font_Blue="\033[34m"
Font_Purple="\033[35m"
Font_SkyBlue="\033[36m"
Font_White="\033[37m"
Font_Suffix="\033[0m"

while getopts ":I:M:E:X:P:F:S:" optname; do
    case "$optname" in
    # "I")
    #     iface="$OPTARG"
    #     useNIC="--interface $iface"
    #     ;;
    # "M")
    #     if [[ "$OPTARG" == "4" ]]; then
    #         NetworkType=4
    #     elif [[ "$OPTARG" == "6" ]]; then
    #         NetworkType=6
    #     fi
    #     ;;
    # "E")
    #     language="e"
    #     ;;
    # "X")
    #     XIP="$OPTARG"
    #     xForward="--header X-Forwarded-For:$XIP"
    #     ;;
    # "P")
    #     proxy="$OPTARG"
    #     usePROXY="-x $proxy"
    # 	;;
    "F")
        func="$OPTARG"
    	;;
    # "S")
    #     Stype="$OPTARG"
    # 	;;
    ":")
        echo "Unknown error while processing options"
        exit 1
        ;;
    esac

done

curlArgs=""
UA="Mozilla"

myip4=$(curl -SsL "ipv4.ip.sb")
myip6=$(curl -SsL "ipv6.ip.sb")
echo "$myip4"
echo "$myip6"

checkCPU() {
    CPUArch=$(uname -m)
    if [[ "$CPUArch" == "aarch64" ]]; then
        arch=arm64
    elif [[ "$CPUArch" == "i686" ]]; then
        arch=i686
    elif [[ "$CPUArch" == "arm" ]]; then
        arch=arm
    elif [[ "$CPUArch" == "x86_64" ]] && [ -n "$ifMacOS" ]; then
        arch=darwin
    elif [[ "$CPUArch" == "x86_64" ]]; then
        arch=amd64
    fi
}
checkCPU

install_nali() {
    if [ -f "/tmp/nali" ];then
        chmod +x /tmp/nali
    else
        curl "https://github.com/nxtrace/nali/releases/latest/download/nali-nt_linux_${arch}" $curlArgs -SsL -o /tmp/nali
        chmod +x /tmp/nali
    fi
    
}
install_nali

function ip_check_ipipnet() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://myip.ipip.net" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ipip.net:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | grep -Eo "来自于.*")
    echo -n -e "\r ipip.net:\t\t\t${Font_Yellow}${result##*：}${Font_Suffix}\n"
    return
}

function ip_check_ipinfo() {
    local tmp=$(curl $curlArgs -${1} -m 10 -SsL "https://ipinfo.io" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ipinfo:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".country" | tr -d '"')
    local result_city=$(echo "$tmp" | jq ".city" | tr -d '"')
    local result_region=$(echo "$tmp" | jq ".region" | tr -d '"')
    if [ "$result_city" == "null" ] && [ "$result_region" == "null" ]; then
        echo -n -e "\r ipinfo:\t\t\t${Font_Yellow}${result}${Font_Suffix}\n"
        return
    fi
    echo -n -e "\r ipinfo:\t\t\t${Font_Yellow}${result} ($result_city/$result_region)${Font_Suffix}\n"
    return
}

function ip_check_ipapico() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://ipapi.co/json" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ipapi.co:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local error=$(echo "$tmp" | jq ".error" | tr -d '"')
    if [[ "$error" == "true" ]]; then
        local error_reason=$(echo "$tmp" | jq ".reason" | tr -d '"')
        echo -n -e "\r ipapi.co:\t\t\t${Font_Red}Failed ($error_reason)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".country" | tr -d '"')
    local result_city=$(echo "$tmp" | jq ".city" | tr -d '"')
    local result_region=$(echo "$tmp" | jq ".region" | tr -d '"')
    if [ "$result_city" == "null" ] && [ "$result_region" == "null" ]; then
        echo -n -e "\r ipapi.co:\t\t\t${Font_Yellow}${result}${Font_Suffix}\n"
        return
    fi
    echo -n -e "\r ipapi.co:\t\t\t${Font_Yellow}${result} ($result_city/$result_region)${Font_Suffix}\n"
    return
}

function ip_check_ip2location() {
    local api_key="0d4f60641cd9b95ff5ac9b4d866a0655"
    #TODO
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://api.ip2location.io/?key=${api_key}" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ip2location:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".country_code" | tr -d '"')
    local result_city=$(echo "$tmp" | jq ".city_name" | tr -d '"')
    local result_region=$(echo "$tmp" | jq ".region_name" | tr -d '"')
    if [ "$result_city" == "null" ] && [ "$result_region" == "null" ]; then
        echo -n -e "\r ip2location:\t\t\t${Font_Yellow}${result}${Font_Suffix}\n"
        return
    fi
    echo -n -e "\r ip2location:\t\t\t${Font_Yellow}${result} ($result_city/$result_region)${Font_Suffix}\n"
    return
}

function ip_check_ipsb() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://api.ip.sb/geoip" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r Maxmind(ip.sb):\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".country_code" | tr -d '"')
    echo -n -e "\r Maxmind(ip.sb):\t\t${Font_Yellow}${result}${Font_Suffix}\n"
    return
}

function ip_check_cloudflare() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://speed.cloudflare.com/meta" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r Maxmind(cloudflare):\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".country" | tr -d '"')
    local result_colo=$(echo "$tmp" | jq ".colo" | tr -d '"')
    echo -n -e "\r Maxmind(cloudflare):\t\t${Font_Yellow}${result} (Colo: $result_colo)${Font_Suffix}\n"
    return
}

function ip_check_google() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://www.google.com/async/lbsc" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r Google:\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [[ "$tmp" == *"websearch/answer/86640"* ]]; then
        echo -n -e "\r Google:\t\t\t${Font_Red}Failed (Unusual Traffic)${Font_Suffix}\n"
        return
    fi 
    local result="$(echo "${tmp}" | grep "location_address" | jq ".BottomSheetParams.payload.bottom_sheet_params.location_address" | tr -d '"')"
    echo -n -e "\r Google:\t\t\t${Font_Yellow}$result${Font_Suffix}\n"
    return
}

function ip_check_ipapicom() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "http://ip-api.com/json" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ip-api.com:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".countryCode" | tr -d '"')
    local result_city=$(echo "$tmp" | jq ".city" | tr -d '"')
    local result_region=$(echo "$tmp" | jq ".regionName" | tr -d '"')
    if [ "$result_city" == "null" ] && [ "$result_region" == "null" ]; then
        echo -n -e "\r ip-api.com:\t\t\t${Font_Yellow}${result}${Font_Suffix}\n"
        return
    fi
    echo -n -e "\r ip-api.com:\t\t\t${Font_Yellow}${result} ($result_city/$result_region)${Font_Suffix}\n"
    return
}

function ip_check_ipregistry() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://api.ipregistry.co/?hostname=true&key=sb69ksjcajfs4c" -H "Origin: https://ipregistry.co" -H "Referer: https://ipregistry.co" -H "Content-Type: application/json" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ipregistry:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".location.country.code" | tr -d '"')
    local result_city=$(echo "$tmp" | jq ".location.city" | tr -d '"')
    local result_region=$(echo "$tmp" | jq ".location.region.name" | tr -d '"')
    if [ "$result_city" == "null" ] && [ "$result_region" == "null" ]; then
        echo -n -e "\r ipregistry:\t\t\t${Font_Yellow}${result}${Font_Suffix}\n"
        return
    fi
    echo -n -e "\r ipregistry:\t\t\t${Font_Yellow}${result} ($result_city/$result_region)${Font_Suffix}\n"
    return
}

function ip_check_tencentmap() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://apis.map.qq.com/ws/location/v1/ip?key=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77" -H "Referer: https://lbs.qq.com/" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r Tencent Map:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local error=$(echo "$tmp" | jq ".status" | tr -d '"')
    if [[ ! "$error" == "0" ]]; then
        local error_reason=$(echo "$tmp" | jq ".message" | tr -d '"')
        echo -n -e "\r Tencent Map:\t\t\t${Font_Red}Failed ($error_reason)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".result.ad_info.nation" | tr -d '"')
    local result_city=$(echo "$tmp" | jq ".result.ad_info.province" | tr -d '"')
    local result_region=$(echo "$tmp" | jq ".result.ad_info.city" | tr -d '"')
    echo -n -e "\r Tencent Map:\t\t\t${Font_Yellow}${result} $result_city $result_region${Font_Suffix}\n"
    return
}

function ip_check_ripe() {
    if [[ ${1} == "4" ]];then
        local tmp_rir=$(curl $curlArgs -A "$UA" -m 10 -SsL "https://stat.ripe.net/data/rir-stats-country/data.json?resource=$myip4" 2>&1)
        local tmp_whois=$(curl $curlArgs -A "$UA" -m 10 -SsL "https://stat.ripe.net/data/whois/data.json?resource=$myip4" 2>&1)
        local tmp_maxmind=$(curl $curlArgs -A "$UA" -m 10 -SsL "https://stat.ripe.net/data/maxmind-geo-lite/data.json?resource=$myip4" 2>&1)
    else
        local tmp_rir=$(curl $curlArgs -A "$UA" -m 10 -SsL "https://stat.ripe.net/data/rir-stats-country/data.json?resource=$myip6" 2>&1)
        local tmp_whois=$(curl $curlArgs -A "$UA" -m 10 -SsL "https://stat.ripe.net/data/whois/data.json?resource=$myip6" 2>&1)
        local tmp_maxmind=$(curl $curlArgs  -A "$UA" -m 10 -SsL "https://stat.ripe.net/data/maxmind-geo-lite/data.json?resource=$myip6" 2>&1)
    fi

    if [[ "$tmp_rir" == "curl"* ]] || [[ "$tmp_whois" == "curl"* ]] || [[ "$tmp_maxmind" == "curl"* ]]; then
        echo -n -e "\r RIPE:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result_rir=$(echo "$tmp_rir" | jq ".data.located_resources[0].location" | tr -d '"')
    local result_rir_inetnum=$(echo "$tmp_rir" | jq ".data.located_resources[0].resource" | tr -d '"')
    local result_whois=$(echo "$tmp_whois" | jq '.data.records[0][]' -c | grep "country" | head -1 | jq ".value" | tr -d '"')
    local result_whois_inetnum=$(echo "$tmp_whois" | jq '.data.records[0][]' -c | grep  -E "inetnum|inet6num" | jq ".value" | tr -d '"')
    local result_maxmind=$(echo "$tmp_maxmind" | jq ".data.located_resources[0].locations[0].country" | tr -d '"')
    if [[ "$result_maxmind" == "?" ]];then
        local result_maxmind_city="Anycast"
    else
        local result_maxmind_city=$(echo "$tmp_maxmind" | jq ".data.located_resources[0].locations[0].city" | tr -d '"')
    fi
    echo -n -e "\r RIR (RIPE):\t\t\t${Font_Yellow}${result_rir} ($result_rir_inetnum)${Font_Suffix}\n"
    if [[ -n "$result_whois" ]];then
        echo -n -e "\r Whois (RIPE):\t\t\t${Font_Yellow}${result_whois} ($result_whois_inetnum)${Font_Suffix}\n"
    else
        echo -n -e "\r Whois (RIPE):\t\t\t${Font_Red}No data (May be ARIN)${Font_Suffix}\n"
    fi
    if [[ -n "$result_maxmind_city" ]];then
        echo -n -e "\r Maxmind (RIPE):\t\t${Font_Yellow}${result_maxmind} ($result_maxmind_city)${Font_Suffix}\n"
    else
        echo -n -e "\r Maxmind (RIPE):\t\t${Font_Yellow}${result_maxmind}${Font_Suffix}\n"
    fi
    return
}

function ip_check_cz88() {
    if [[ "${1}" == "6" ]];then
        local tmp=$(curl $curlArgs -A "$UA" -m 10 -SsL "https://cz88.net/api/cz88/ip/base?ip=${myip6}" 2>&1)
    else
        local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://cz88.net/api/cz88/ip/base?ip=" 2>&1)
    fi
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r CZ88:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".data.countryCode" | tr -d '"')
    local result_full=$(echo "$tmp" | jq ".data.actionAddress[0]" | tr -d '"')
    echo -n -e "\r CZ88:\t\t\t\t${Font_Yellow}${result} ($result_full)${Font_Suffix}\n"
    return
}

function ip_check_zxnic() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://ip.zxinc.org/api.php?type=json" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ZXNIC:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".data.location" | tr -d '"')
    echo -n -e "\r ZXNIC:\t\t\t\t${Font_Yellow}${result}${Font_Suffix}\n"
    return
}

function ip_check_LeoMoeAPI() {
    if [[ ${1} == "6" ]];then
        local tmp=$(/tmp/nali ${myip6} 2>&1)
    else
        local tmp=$(/tmp/nali ${myip4} 2>&1)
    fi
    local result=$(echo "$tmp" | grep -Eo "\[.*\]")
    echo -n -e "\r LeoMoeAPI:\t\t\t${Font_Yellow}${result:1:-1}${Font_Suffix}\n"
    return
}

function ip_check_ipgeolocation() {
    local tmp=$(curl $curlArgs -${1} -A "$UA" -m 10 -SsL "https://api.ipgeolocation.io/ipgeo?include=hostname" -H "Referer:https://ipgeolocation.io/" 2>&1)
    if [[ "$tmp" == "curl"* ]]; then
        echo -n -e "\r ipGeolocation:\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    local result=$(echo "$tmp" | jq ".country_code2" | tr -d '"')
    local result_city=$(echo "$tmp" | jq ".city" | tr -d '"')
    local result_region=$(echo "$tmp" | jq ".state_prov" | tr -d '"')
    if [ "$result_city" == "null" ] && [ "$result_region" == "null" ]; then
        echo -n -e "\r ipGeolocation:\t\t\t${Font_Yellow}${result}${Font_Suffix}\n"
        return
    fi
    echo -n -e "\r ipGeolocation:\t\t\t${Font_Yellow}${result} ($result_city $result_region)${Font_Suffix}\n"
    return
}

if [ -n "$func" ]; then
    echo -e "${Font_Green}IPv4:${Font_Suffix}" 
    $func 4
    echo -e "${Font_Green}IPv6:${Font_Suffix}" 
    $func 6
    exit
fi
echo -e "${Font_Green}IPv4:${Font_Suffix}" 
ip_check_ipipnet 4 
ip_check_ipinfo 4 
ip_check_ipapico 4
ip_check_ip2location 4
ip_check_ipsb 4
ip_check_cloudflare 4
ip_check_google 4 
ip_check_ipapicom 4
ip_check_ipregistry 4
ip_check_tencentmap 4
ip_check_ripe 4
ip_check_cz88 4
ip_check_zxnic 4
ip_check_LeoMoeAPI 4
ip_check_ipgeolocation 4
if [[ -z "$myip6" ]]; then
exit
fi
echo -e "${Font_Green}IPv6:${Font_Suffix}" 
# ip_check_ipipnet 6
# ip_check_ipinfo 6
ip_check_ipapico 6
ip_check_ip2location 6
ip_check_ipsb 6
ip_check_cloudflare 6
ip_check_google 6
ip_check_ipregistry 6
ip_check_tencentmap 6
ip_check_ripe 6
ip_check_cz88 6
ip_check_zxnic 6
ip_check_LeoMoeAPI 6
ip_check_ipgeolocation 6