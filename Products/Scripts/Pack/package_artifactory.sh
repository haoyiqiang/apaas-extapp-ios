#!/bin/sh
Color='\033[1;36m'
Res='\033[0m'

# parameters
SDK_Name=$1
Repo_Name="open-apaas-extapp-ios"

echo "$Color ======$SDK_Name Package Artificatory======== $Res"

# path
Current_Path=`pwd`

cd $(dirname $0)

echo pwd: `pwd`

CICD_Root_Path=../../../../apaas-cicd-ios
CICD_Products_Path=${CICD_Root_Path}/Products
CICD_Scripts_Path=${CICD_Products_Path}/Scripts

# pack
${CICD_Scripts_Path}/SDK/Pack/v1/package.sh ${SDK_Name} ${Repo_Name}

# upload
cd ../../../Package

python3 ${WORKSPACE}/artifactory_utils.py --action=upload_file --file=${SDK_Name}*.zip --project

# error & exit
if [ $? != 0 ]; then
    echo "$Color ======$SDK_Name Package Artificatory Fails======== $Res"
    
    exit -1
else
    echo "$Color ======$SDK_Name Package Artificatory Succeeds======== $Res"
fi

# remove
rm ${SDK_Name}*.zip

cd ${Current_Path}