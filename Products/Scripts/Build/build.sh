#!/bin/bash
# parameters
SDK_Name=$1
Repo_Name="open-apaas-extapp-ios"

# path
cd $(dirname $0)

echo pwd: `pwd`

CICD_Root_Path="../../../../apaas-cicd-ios"
CICD_Products_Path="${CICD_Root_Path}/Products"
CICD_Scripts_Path="${CICD_Products_Path}/Scripts"

# build
${CICD_Scripts_Path}/SDK/Build/v1/build.sh ${SDK_Name} ${Repo_Name}