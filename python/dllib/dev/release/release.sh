#!/usr/bin/env bash

#
# Copyright 2016 The BigDL Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e
RUN_SCRIPT_DIR=$(cd $(dirname $0) ; pwd)
echo $RUN_SCRIPT_DIR
BIGDL_DIR="$(cd ${RUN_SCRIPT_DIR}/../../../..; pwd)"
echo $BIGDL_DIR
BIGDL_PYTHON_DIR="$(cd ${BIGDL_DIR}/python/dllib/src; pwd)"
echo $BIGDL_PYTHON_DIR

if (( $# < 4)); then
  echo "Usage: release.sh platform version quick_build upload mvn_parameters"
  echo "Usage example: bash release.sh linux default false true"
  echo "Usage example: bash release.sh mac 0.14.0.dev1 true true"
  echo "you can also add other profiles such as: -Dspark.version=2.4.6 -P spark_2.x"
  exit -1
fi

platform=$1
version=$2
quick=$3 # Whether to rebuild the jar; quick=true means not rebuilding the jar
upload=$4  # Whether to upload the whl to pypi
profiles=${*:5}

if [ "${version}" != "default" ]; then
    echo "User specified version: ${version}"
    echo $version > $BIGDL_DIR/python/version.txt
fi

bigdl_version=$(cat $BIGDL_DIR/python/version.txt | head -1)
echo "The effective version is: ${bigdl_version}"

echo "__version__ = '"$bigdl_version"'" > $BIGDL_PYTHON_DIR/bigdl/dllib/version.py

cd ${BIGDL_DIR}/scala
if [ "$platform" ==  "mac" ]; then
    echo "Building bigdl for mac system"
    dist_profile="-P mac $profiles"
    verbose_pname="macosx_10_11_x86_64"
elif [ "$platform" == "linux" ]; then
    echo "Building bigdl for linux system"
    dist_profile="-P linux $profiles"
    verbose_pname="manylinux1_x86_64"
else
    echo "Unsupported platform"
fi

bigdl_build_command="bash make-dist.sh ${dist_profile}"
if [ "$quick" == "true" ]; then
    echo "Skip disting BigDL"
else
    echo "Dist BigDL: $bigdl_build_command"
    cd ${BIGDL_DIR}/scala
    $bigdl_build_command
fi

if [ -d "${BIGDL_DIR}/python/dllib/src/build" ]; then
   rm -r ${BIGDL_DIR}/python/dllib/src/build
fi

if [ -d "${BIGDL_DIR}/python/dllib/src/dist" ]; then
   rm -r ${BIGDL_DIR}/python/dllib/src/dist
fi

if [ -d "${BIGDL_DIR}/python/dllib/src/bigdl_dllib.egg-info" ]; then
   rm -r ${BIGDL_DIR}/python/dllib/src/bigdl_dllib.egg-info
fi

if [ -d "${BIGDL_DIR}/python/dllib/src/bigdl/scripts" ]; then
   rm -r ${BIGDL_DIR}/python/dllib/src/bigdl/scripts
fi
cp -r ${BIGDL_DIR}/scripts/ ${BIGDL_DIR}/python/dllib/src/bigdl/scripts

cd $BIGDL_PYTHON_DIR
wheel_command="python setup.py sdist bdist_wheel --plat-name ${verbose_pname} --python-tag py3"
echo "Packing python source code and distribution: $wheel_command"
${wheel_command}

if [ ${upload} == true ]; then
    upload_wheel_command="twine upload dist/bigdl_dllib-${bigdl_version}-py3-none-${verbose_pname}.whl"
    echo "Uploading wheel with this command: $upload_wheel_command"
    $upload_wheel_command
    if [ "$platform" == "linux" ]; then
        upload_source_command="twine upload dist/bigdl-dllib-${bigdl_version}.tar.gz"
        echo "Uploading source with this command: $upload_source_command"
        $upload_source_command
    fi
fi
