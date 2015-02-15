#!/bin/sh

# git 工作目录
#wkp="/root/.jenkins/jobs/tw/workspace/"
wkp=${WORKSPACE}/
if [ ! -s ${wkp} ]; then
    echo "can not found workspace (${wkp}), program exit"
    exit 1 
fi
#echo "workspace ${wkp}"

# 需更新的部分
if [ ! -n "$cpp"  ]; then
    #cpp="$wkp"
    cpp="src/main/webapp/"
fi
echo "update dir ${cpp}"
cpp=${wkp}${cpp}

# 更新临时文件夹名称
if [ ! -n "$upn"  ]; then
    upn="update_tmp"
fi
upnP="${upn}/"
updateW="${wkp}${upnP}"
echo "update tmp ${upnP}"

cd $wkp

update="true"
deleteW="false"

fileP="${wkp}update_lastPull"
echo "update key update_lastPull"
if [ ! -s ${fileP} ]; then
    update="false"
fi
echo "update model: ${update}" 

lp=`cat ${fileP}`
hd=`cat ${wkp}.git/HEAD`
if [ "$lp" = "$hd" ]; then
    echo "no file change"
    exit 0
fi

if [ "$update" = "true" ]; then
    if [ -s ${updateW} ]; then
        llp="${upn}_${lp}"
        echo "backup ${upn} to ${llp}"
        if [ -s ${wkp}${llp}  ]; then
            rm -rf ${llp}
        fi
        mv -f $upn ${llp}
    fi
    echo "create $upnP"
    mkdir -p $updateW
    td=`git diff --diff-filter=[ADM] --name-status $lp -- $cpp | awk '
        {
          if ($1 == "D") { 
            { print "echo "$2" >> "uw"delFiles.txt;" }
          } else {
            { print "mkdir -p \`dirname "uw$2"\`;" }
            { print "\\\cp -f "$2" "uw$2";" }
          } 
        }
    ' uw="${upn}/"`
    echo "copy files to ${upnP}"
    eval $td
fi


echo "update to commit $hd"

if [ "$update" = "false" ]; then
    echo "create $updateW"
    mkdir -p $updateW
    cp -R "${cpp}" $updateW
fi

echo -n "$hd" > $fileP

if [ "$deleteW" = "true" ]; then
    echo "delete $updateW"
    rm -rf $updateW
fi

# for jenkins
exit 0