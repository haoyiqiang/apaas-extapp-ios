#!/bin/bash
# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# import 
. ../../../../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# parameters
SDK_Name=$1
Repo_Name="open-apaas-extapp-ios"

parameterCheckPrint ${SDK_Name}

startPrint "${SDK_Name} Download Dependency Libs"

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
    python3 ${WORKSPACE}/artifactory_utils.py --action=download_file --file=${SDK_URL}
done

errorPrint $? "${SDK_Name} Download Dependency Libs"

echo Dependency Libs

ls

for SDK in ${Dep_Array[*]}
do
    Zip_File=${SDK}*.zip

    # move
    mv -f ./${Zip_File}  ${Root_Path}/

    # unzip
    echo Repo_Name--  ${Repo_Name}

    ${Root_Path}/../apaas-cicd-ios/Products/Scripts/SDK/Build/v1/unzip.sh ${SDK} "${Repo_Name}"
done

endPrint $? "${SDK_Name} Download Dependency Libs"