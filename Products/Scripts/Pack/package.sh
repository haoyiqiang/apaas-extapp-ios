#!/bin/sh
SDK_Name=$1
Package_Path="../../../Package"
Product_Path="../../"
Product_Libs_Path=${Product_Path}/Libs

rm -rf ${Package_Path}/*

mkdir -p ${Package_Path}/${SDK_Name}/

cp -r ${Product_Libs_Path}/* ${Package_Path}/${SDK_Name}

cd ${Package_Path}

Timestamp=`date '+%Y%m%d_%H%M'`

Zip_File=${SDK_Name}_${Timestamp}.zip

zip -r ${Zip_File} ./*

rm -rf ${SDK_Name}
