#!/bin/bash
Color='\033[1;36m'
Res='\033[0m'

SDK_Name=$1

Current_Path=`pwd`
SDKs_Path="../../../SDKs"
Products_Root_Path="../../Libs"
Products_Path="$Products_Root_Path/$SDK_Name"
Builder_Path="${SDKs_Path}/AgoraBuilder"

if [ ! -d $Products_Root_Path ];then
    mkdir $Products_Root_Path
fi

rm -rf ${Products_Path}
mkdir ${Products_Path}

errorExit() {
    SDK_Name=$1
    Build_Result=$2

    if [ $Build_Result != 0 ]; then
        echo "SDK_Name: ${SDK_Name}"
        exit 1
    fi
    echo "build result: $Build_Result"
    echo "${SDK_Name} build success"
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
        
        dependencyPath="$repoPath/Products/Libs/$libName/$libName.framework"
        
        # call buildframework of dependency
        if [ ! -f $dependencyPath ]; then
            echo $dependencyPath
            exit 1
            cd $repoPath/Products/Scripts/SDK
            sh buildframework.sh $libName
            cd $Current_Path
        fi
    done
    
    cd $Current_Path
}

echo "${Color} ======${SDK_Name} Start======== ${Res}"

dependencyCheck

# current path is under Products/Scripts/SDK
./buildExecution.sh $Builder_Path ${SDK_Name} Release

errorExit ${SDK_Name} $?
