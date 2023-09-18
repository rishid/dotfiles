

#
# General
#

# curl with client cert
alias curlcc='curl --cert ~/.certs/$USER.crt --key ~/.certs/$USER.key'





#
# AppBattery
#
appbattery_list_logs()
{
    typeset app_name=$1
    curlcc https://ab-logs.akamai.com/app/$app_name/list_log_names
}

appbattery_get_log()
{
    typeset app_name=$1
    typeset log_name=$2
    curlcc https://ab-logs.akamai.com/app/$app_name?log_name=$log_name
}

appbattery_get_app_log()
{
    typeset app_name=$1
    curlcc https://ab-logs.akamai.com/app/$app_name?log_name=app0-stdout.log
}

appbattery_push_latest()
{
    typeset app_name=$1
    curlcc -X PUT -H "Content-Type: application/json" https://ab-ws.akamai.com/api/v2/apps/env/production/cluster/hh/app/$1/traffic-split -d "{}"
}

appbattery_what_is_running()
{
    typeset app_name=$1
    curlcc https://ab-ws.akamai.com/api/v2/apps/env/production/cluster/hh/app/$1/traffic-split
}

appbattery_stats()
{
    typeset app_name=$1
    curlcc -w '' https://ab-ws.akamai.com/api/v2/apps/env/production/table/abattery_running_app_status/stats?app=$1  | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv'
}

appbattery_set_permissions()
{
    typeset app_name=$1
    array=(dtang vipatel mavery caross pchin palynch aashah cgero)
    for i in "${array[@]}"
    do
        http --cert ~/.certs/$USER.crt --cert-key ~/.certs/$USER.key DELETE https://ab-ws.akamai.com/api/v2/apps/env/production/cluster/hh/app/${app_name}/config/users/${i}/permissions/admin
        http --cert ~/.certs/$USER.crt --cert-key ~/.certs/$USER.key DELETE https://ab-ws.akamai.com/api/v2/apps/env/production/cluster/hh/app/${app_name}/config/users/${i}/permissions/admin
    done

    for i in "${array[@]}"
    do
        http --cert ~/.certs/$USER.crt --cert-key ~/.certs/$USER.key PUT https://ab-ws.akamai.com/api/v2/apps/env/production/cluster/hh/app/${app_name}/config/users/${i}/permissions/admin
    done
}

#
# Bart
#
bart_trigger_build()
{
    typeset bart_comp_name=$1
    typeset bart_version=$2
    readarray -t bart_ids < <(curlcc -s -w '' https://release-api.akamai.com/r4/api/v1/components/${bart_comp_name}/versions/${bart_version}/build_platforms | jq -r '.[] | .id' )
    for id in ${bart_ids[@]}; do
        echo "Triggering build for bart-id ${id}"
        curlcc -s --output /dev/null -X POST -H "Content-Type: application/json" -d '' "https://release-api.akamai.com/rails/api/builds/request_builds?component_ids=${id}&notify_users=${USER}"
    done
}

#
# DataBattery
#
databattery_url="https://api-prod.dbattery.akamai.com/v1/apps/ztcore/"

alias dbattery-post="curlcc -XPOST -H \"Content-Type: application/json\" "
alias dbattery-put="curlcc -XPUT -H \"Content-Type: application/json\" "
alias dbattery-get="curlcc "
alias dbattery-del="curlcc -XDELETE "
