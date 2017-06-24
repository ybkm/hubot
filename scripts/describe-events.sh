#! /bini/bash

# パス設定
PATH="/usr/bin/aws:/bin:/usr/bin"

# 変数設定
logfile_path="./scripts/var/log/"
log_file="${logfile_path}aws_describe.log.`date +%Y%m%d%H%M`"

arr_profile=(aliasA aliasB aliasC)

# リージョンリストの取得
regions=`aws ec2 describe-regions --profile mdjtech | jq '.Regions | .[].RegionName' | sed -e 's/\"//g'`

# ログファイル初期化
cat /dev/null > $log_file

# 実行時間
echo "==== 取得日次: "`date +"%Y/%m/%d %H:%M"` >> $log_file 

# main処理
for profile in ${arr_profile[@]}
do
  echo "#### $profile" >> $log_file
  echo "$regions" | while read region
  do
    echo "==== $region" >> $log_file
      event_result=""
      instance_id=""
      host_name=""
      # event取得
      event_result=`aws ec2 describe-instance-status --profile $profile \
        --region $region \
        --filters Name=event.code,Values=instance-reboot,system-reboot,system-maintenance,instance-retirement,instance-stop | \
        jq -r '.InstanceStatuses[] | "\(.InstanceId), \(.Events[] | .Description), \(.Events[] | .NotBefore), \(.Events[] | .NotAfter)"'`

      if [ ! -z "${event_result}" ]; then
        echo "${event_result}" | while read event_line
        do
          # ホスト名取得
          instance_id=`echo ${event_line} | cut -d',' -f1`
          host_name=`aws ec2 describe-instances --profile $profile \
            --region $region \
            --instance-ids ${instance_id} | \
            jq -r '.Reservations[].Instances[].Tags[] | select(.Key == "Name").Value'`
          if [ ! -z "${instance_id}" ]; then
            echo "${instance_id}(${host_name}),${event_line}" >> $log_file
          fi
        done
      fi
  done
  echo "" >> $log_file
done

function check_timestamp(){
  file_date=`sed -n 2P $1 | rev | cut -c 7-11 | rev`
  if [ $file_date = `date +"%m/%d"` ]; then
    return true
  else 
    return false
  fi
}

function filter_logfile(){
  target_instanc=""
  event_description=""
  not_before=""
  not_after=""
  event_comment=""
  cat $1 | while read log_line
  do
    if [[ `echo ${log_line} | egrep '####'` ]]; then
      echo -e "\n${log_line}"
    elif [[ `echo "${log_line}" | egrep -v '====|####'` ]]; then
      target_instance=`echo "${log_line}" | cut -d',' -f1`
      event_description=`echo "${log_line}" | cut -d',' -f3`
      not_before=`echo "${log_line}" | cut -d',' -f4`
      not_after=`echo "${log_line}" | cut -d',' -f5`
      event_comment="${target_instance}が${event_description}だって。\n時間は${not_before} ～${not_after}"
      echo -e "${event_comment}"
    fi
  done
}

if [ ! -f $log_file ]; then
  echo -e "aws cliが正常に呼べなかったみたいね"
  exit 9
elif [ -z `cat ${log_file} | egrep -v '====|####'` ]; then
  echo "今はec2 eventを気にする必要はないみたいね"
  exit 0
elif [ "check_timestamp ${log_file}" ]; then
  filter_logfile "${log_file}"
  echo "日本時間にしたいなら+9時間してね"
  exit 0
else
  echo -e "errorみたいね"
  exit 9
fi

# ログファイル削除

# find ${logfile_path} -name 'aws_describe.log.*' -mtime +14 -delete
find ${logfile_path} -name 'aws_describe.log.*' -m 10 -delete
