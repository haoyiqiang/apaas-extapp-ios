#!/bin/bash
# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# parameters
SDK_Name=$1
Repo_Name="open-apaas-extapp-ios"

# path
Root_Path="../../.."

# Dependency libs
# UIBaseViews
# Widget
Dep_Array_URL=("https://artifactory.agoralab.co/artifactory/AD_repo/apaas_common_libs_ios/cavan/20230302/ios/AgoraUIBaseViews_2.8.0_82.zip"
               "https://artifactory.agoralab.co/artifactory/AD_repo/apaas_common_libs_ios/cavan/20230302/ios/AgoraWidget_2.8.0_82.zip")

Dep_Array=(AgoraUIBaseViews 
           AgoraWidget)

for SDK_URL in ${Dep_Array_URL[*]} 
do
    echo ${SDK_URL}
   # python3 ${WORKSPACE}/artifactory_utils.py --action=download_file --file=${SDK_URL}
done

for SDK in ${Dep_Array[*]}
do
    Zip_File=${SDK}*.zip

    # move
    mv -f ./${Zip_File}  ${Root_Path}/

    # unzip
    ${Root_Path}/../apaas-cicd-ios/Products/Scripts/SDK/Build/v1/unzip.sh ${SDK_Name} ${Repo_Name}
done