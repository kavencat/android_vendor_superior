#!/bin/bash
# Copyright (C) 2020-23 The Superior OS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

device=$1
sourcerom=aosp

DATE="$(grep ro.build.date.utc ~/$sourcerom/out/target/product/$device/system/build.prop | cut -d'=' -f2)"

if [ -z "$DATE" ]; then
  echo "ERROR: Failed to retrieve build date"
  exit 1
fi

# make DATE human readable like 20230203
BUILDDATE="$(date -d @$DATE +%Y%m%d)"
DAY="$(date -d @$DATE +%d/%m/%Y)"

# get the zip path from out folder using the date
zip_path=~/$sourcerom/out/target/product/$device/$2
echo $zip_path
# don't fail if there is no device json
set +e

if [ -d ~/tequila_ota ]; then

  # datetime
  timestamp=$(cat ~/$sourcerom/out/target/product/$device/system/build.prop | grep ro.build.date.utc | cut -d'=' -f2)
  # filename
  zip_name=$(cat ~/$sourcerom/out/target/product/$device/system/build.prop | grep ro.superior.version | cut -d'=' -f2)
  # id
  id=$(sha256sum $zip_path | cut -d' ' -f1)
  # Rom type
  type="RELEASE"
  # Rom size
  size_new=$(stat -c "%s" $zip_path)
  # Rom version
  version=$(cat ~/$sourcerom/out/target/product/$device/system/build.prop | grep ro.modversion | cut -d'=' -f2)
  # url
  BUILD_DATE=$(echo $zip_name | cut -d "-" -f6)
  BUILD_YEAR=${BUILD_DATE:0:4}
  BUILD_MONTH=${BUILD_DATE:4:2}
  BUILD_DAY=${BUILD_DATE:6:2}
  url="https://sourceforge.net/projects/wayney/files/"$BUILD_YEAR"-"$BUILD_MONTH"-"$BUILD_DAY"/"$zip_name".zip/download"
fi

# if there is no json file, create one
if [ ! -f ~/tequila_ota/devices/SuperiorOS_$device.json ]; then
  echo "No json file found, creating one"
  echo "Creating json file for $device"
  echo "{
  \"response\": [
    {
      \"datetime\": $timestamp,
      \"filename\": \"$zip_name.zip\",
      \"id\": \"$id\",
      \"romtype\": \"$type\",
      \"size\": $size_new,
      \"url\": \"$url\",
      \"version\": \"$version\",
      \"device_name\": \"wayne\",
      \"maintainer\": \"kavencat\"
    }
  ]
}" >~/tequila_ota/devices/SuperiorOS_$device.json
  sleep 1
  echo "Done"
fi

if [ ! -f ~/tequila_ota/changlogs/SuperiorOS_changelogs_wayne.txt ]; then
echo -e 'device:'$device'
model:Mi 6X 
'$(echo $(date "+%Y-%m-%d"))'\n'$(echo $device: update $DAY) >> ~/tequila_ota/changlogs/SuperiorOS_changelogs_wayne.txt
cat /home/linuxlite/桌面/update | while read line
do
	echo ${line} >> ~/tequila_ota/changlogs/SuperiorOS_changelogs_wayne.txt
done
  sleep 1
  echo "Done"
fi
