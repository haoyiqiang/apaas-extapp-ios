#!/bin/sh
cd $(dirname $0)

SDK_Name="AgoraWidgets"
./publish_cocoapods.sh ${SDK_Name}
