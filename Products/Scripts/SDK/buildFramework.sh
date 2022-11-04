#!/bin/bash
Color='\033[1;36m'
Res='\033[0m'

SDK_Name=$1

Current_Path=$(cd "$(dirname "$0")";pwd)
SDKs_Path="$Current_Path/../../../SDKs"
Products_Root_Path="$Current_Path/../../Libs"
Products_Path="$Products_Root_Path/$SDK_Name"
Builder_Path="${SDKs_Path}/AgoraBuilder"

if [ ! -d $Products_Root_Path ];then
    mkdir $Products_Root_Path
fi

rm -rf ${Products_Path}
mkdir ${Products_Path}

errorExit() {
    Build_Result=$1

    if [ $Build_Result != 0 ]; then
        echo "${Color} ======${SDK_Name} Fails======== ${Res}"
        exit -1
    fi

    echo "${Color} ======${SDK_Name} Succeeds======== ${Res}"
}

dependencyCheck() {
    cd $Builder_Path
    
    cat Podfile | while read rows
    do
        if [[ $rows != *"/Binary"* ]];then
            continue
        fi
    
        # remove space
        line=`echo $rows | sed s/[[:space:]]//g`
        
        libName=`echo $line | sed "s:pod\'\(.*\)\/Binary.*:\1:g"`
        repoPath=`echo $line | sed "s:.*\:path=>\'\(.*\)\/$libName.*\':\1:g"`

        repoAbsolutePath=$Builder_Path/$repoPath

        dependencyPath="$repoAbsolutePath/Products/Libs/$libName/$libName.framework"
        
         # dependency check
        if [ -d $dependencyPath ]; then
            continue
        fi
        
        # call buildframework
        echo "dependencyPath: $dependencyPath not found"
        
        dependencySDKPath="$repoAbsolutePath/Products/Scripts/SDK"
        if [ ! -d $dependencySDKPath ]; then
            pwd
            echo "dependencySDKPath not found: $dependencySDKPath"
            exit
        fi
        
        echo "$SDK_Name call build: $libName"
        sh $dependencySDKPath/buildframework.sh $libName

        if [ $? -ne 0 ];then
            exit 1
        fi

        cd $Current_Path
    done
    
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    cd $Current_Path
}

echo "${Color} ======${SDK_Name} Start======== ${Res}"

dependencyCheck

if [ $? -ne 0 ]; then
    errorExit 1
fi

# current path is under Products/Scripts/SDK
./buildExecution.sh $Builder_Path ${SDK_Name} Release

errorExit $?
