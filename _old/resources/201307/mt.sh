#!/bin/sh
debug="false"
dir=$(cd "$(dirname "$0")"; pwd)"/"
config_file="${dir}config.ini"

if [ ! -s ${config_file} ]; then
  echo "配置文件不存在 ${config_file}，退出监听" 
  exit 1
fi

function getconfigmodify(){
  config_file_modify=`stat ${config_file} |grep Modify |awk -F': ' '{print $2}'`
}
getconfigmodify
c_file_modify=$config_file_modify

p_name="init"
function setpid(){
  #当前用户的进程
  pid=`ps ux|grep ${p_name}|grep -v grep|sed -n '1p'|awk '{print $2}'`
}
setpid
s_time=900
sr_time=300
over_time=3
sample_dir=$dir
mail_on="false"
msg_on="false"

max_cpu=100
max_mem=40
max_netstat=400
max_lsof=10000

over=0

ip="127.0.0.1"
eth=""
function setip(){
  if [ -n "$eth" ]; then
    ip=`ifconfig ${eth} |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " "`
  fi
}
setip

gdate='${date}'

function getconfig(){
while read line;
do
  if echo $line|grep -v "#"|grep -v ^$ > /dev/null 2>&1
  then
    eval $(echo $line|awk -F '=' '{print "name="$1" value=\""$2"\""}')
    if [ -n "$value" ]; then
      case ${name} in
      'p_name')
        p_name=$value
        setpid
      ;;
      'eth')
        eth=$value
        setip
      ;;
      's_time') s_time=$value
      ;;
      'sr_time') sr_time=$value
      ;;
      'over_time') over_time=$value
      ;;
      'sample_dir') sample_dir=$value
      ;;
      'run') runs[${#runs[@]}]=$value
      ;;
      'mail_on') mail_on=$value
      ;;
      'mail_to') mails_to[${#mails_to[@]}]=$value
      ;;
      'msg_on') msg_on=$value
      ;;
      'msg_url') msg_url=$value
      ;;
      'msg_to') msgs_to[${#msgs_to[@]}]=$value
      ;;
      'max_cpu') max_cpu=$value
      ;;
      'max_mem') max_mem=$value
      ;;
      'max_netstat') max_netstat=$value
      ;;
      'max_lsof') max_lsof=$value
      ;;
      esac
    fi
  fi
done < ${config_file}

turn_time=$s_time

}

getconfig

send_title=""
send_content=""

function getdate(){
 return "`date +"%Y%m%d%H%M%S"`"
}

function sendmail(){
  for email in ${mails_to[@]}
  do
    echo "${send_content}"|mail -s "${send_title}" ${email} -- -f web_error@rongji.com
  done
}

function sendmsg(){
  if [ -n "$msg_url" ]; then
    for msg in ${msgs_to[@]}
    do
      if [ -n "$msg" ]; then
        http_code=`curl -o /dev/null -s -m 10 --connect-timeout 10 -w %{http_code} "$msg_url"`
      fi
    done
  fi
}

function sampling(){
  for i in $(seq ${#runs[@]})
  do
    date="`date +"%Y%m%d%H%M%S"`"
    run="${runs[`expr $i - 1`]}"
    if [ "$debug" = "true" ] || [ "$1" = "one" ]; then
      echo "${run}"
    fi
    eval $(echo ${run})
  done
}

function send(){
  if [ "$mail_on" = "true" ]; then
    sendmail
  fi
  if [ "$msg_on" = "true" ]; then
    sendmsg
  fi
}

function addlog(){
  log_file="${sample_dir}monitoring_${p_name}_`date +"%Y-%m-%d"`.log"
  if [ ! -s ${log_file} ]; then
    touch ${log_file} 
  fi
  send_content="[`date +"%Y-%m-%d %H:%M:%S"`] cpu=${cpu} mem=${mem} netstat_p=${nets_p_name} netstat_t=${nets_tcp} netstat_a=${nets_all} lsof_p=${lsof_p} lsof_a=${lsof_all} ${send_title}"
 echo -e "${send_content}\n"  >> ${log_file}
}

function monitoring(){
  cpu=0
  mem=0
  time=0
  eval $(echo `top -b -n 1 -p ${pid}|sed -n '8p'|awk '{print "cpu="$9" mem="$10" time="$11}'`)
  #echo "${cpu},${mem},${time}"
  
  nets_p_name=`netstat -apn|grep ${pid}/${p_name}|wc -l`
  nets_tcp=`netstat -tnp|wc -l`
  nets_all=`netstat -anp|wc -l`
  #echo "${nets_p_name},${nets_tcp},${nets_all}"

  lsof_p=`lsof -p ${pid}|wc -l`
  lsof_all=`lsof|wc -l`
  #echo "${lsof_p},${lsof_all}"

  #if [ "$cpu" -gt "$max_cpu" ]; then
  if [ `echo "$cpu $max_cpu"|awk '{print ($1 > $2)?"1":"0"}'` -eq "1" ]; then
    send_title="cpu_use[${cpu}] ${send_title}"
  fi
  #if [ $mem -gt $max_mem ]; then
  if [ `echo "$mem $max_mem"|awk '{print ($1 > $2)?"1":"0"}'` -eq "1" ]; then
    send_title="mem_use[${mem}] ${send_title}"
  fi
  if [ $nets_p_name -gt $max_netstat ]; then
    send_title="netstat[${nets_p_name}] ${send_title}"
  fi
  if [ $lsof_all -gt $max_lsof ]; then
    send_title="lsof[${lsof_all}] ${send_title}"
  fi

  addlog
  if [ -n "$send_title" ]; then

    if [ "$debug" = "true" ]; then
      echo -e "[`date +"%Y-%m-%d %H:%M:%S"`] 存在异常 ${send_title}\n"
    fi
    over=`expr $over + 1` 
    if [ "$over" -ge "$over_time" ]; then
      sampling
      send
      over=0
      if [ "$debug" = "true" ]; then
        echo "发送信息"
      fi
    fi
    turn_time=$sr_time
    unset send_title
    unset send_content
  else
    turn_time=$s_time
  fi
}

if [ -z "$pid" ]; then
  echo "指定程序不存在 ${p_name}，退出监听"
  exit 1
fi

if [ "$debug" = "true" ] || [ "$1" = "one" ]; then
  echo "监听程序pid $pid"
  echo -e "监听程序名称 $p_name\n"
fi

if [ "$debug" = "true" ]; then
  echo "开始监听...."
fi

if [ "$1" = "one" ]; then
  echo "开始采样 ${pid}/${p_name}"
  sampling
  echo "完成采样"
  exit 1
fi

while [ 1 -eq 1 ]
do
  getconfigmodify
  plc=`top -b -n 1 -p ${pid}|wc -l`
  if [ "${c_file_modify}" != "${config_file_modify}"  ] || [ "$plc" -eq "8" ]; then
    if [ "$debug" = "true" ]; then
      echo "更新配置文件"
    fi
    unset runs
    unset mails_to
    unset msgs_to
    getconfig
    c_file_modify=$config_file_modify
  fi
  monitoring
  sleep $turn_time
  if [ "$debug" = "true" ]; then
    echo "重新开始...."
  fi
done
