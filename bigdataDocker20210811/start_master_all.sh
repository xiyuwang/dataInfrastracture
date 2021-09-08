#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Start all hadoop daemons.  Run this on master node.
DOCKER_COMMAND="docker exec -it $1 /bin/bash -c "

# format hdfs
echo "hdfs format begin....................."
${DOCKER_COMMAND} "hadoop namenode -format -nonInteractive"
if [ $? -ne 0 ]; then
    echo "fialed when executing hadoop namenode -format -nonInteractive"
    exit 1;
fi
echo "hdfs format end......................."

# start hadoop
echo "start hadoop begin...................."
${DOCKER_COMMAND} "${HADOOP_HOME}/sbin/start-all.sh"
if [ $? -ne 0 ]; then
    echo "fialed when executing ${HADOOP_HOME}/sbin/start-all.sh"
    exit 1;
fi
echo "start hadoop end......................"
echo "start hdfs begin......................"
#${DOCKER_COMMAND} "${HADOOP_HOME}/sbin/start-dfs.sh"
if [ $? -ne 0 ]; then
    echo "fialed when executing ${HADOOP_HOME}/sbin/start-dfs.sh"
    exit 1;
fi
echo "start hdfs end......................."
echo "start yarn begin....................." 
#${DOCKER_COMMAND} "${HADOOP_HOME}/sbin/start-yarn.sh"
if [ $? -ne 0 ]; then
    echo "fialed when executing ${HADOOP_HOME}/sbin/start-yarn.sh"
    exit 1;
fi
echo "start yarn end........................"
echo "start jobhistory begin................"
${DOCKER_COMMAND} "${HADOOP_HOME}/sbin/mr-jobhistory-daemon.sh start historyserver"
if [ $? -ne 0 ]; then
    echo "fialed when executing ${HADOOP_HOME}/sbin/mr-jobhistory-daemon.sh start historyserver"
    exit 1;
fi
echo "start jobhistory end.................."

# create database for hive
echo "create hive meta database begin......."
#mysql -h localhost -P 3307 -u miner -p -e 'create database hive CHARACTER SET utf8mb4;'
if [ $? -ne 0 ]; then
    echo "fialed when executing mysql -h localhost -P 3307 -u miner -p -e 'create database hive CHARACTER SET utf8mb4;'"
    exit 1;
fi
echo "create hive meta database end........."

# start hive
echo "init hive schema begin....................."
${DOCKER_COMMAND} "${HIVE_HOME}/bin/schematool -dbType mysql -initSchema"
echo "init hive schema end......................."
#echo "start hive begin......................"
#${DOCKER_COMMAND} "hive"
#echo "start hive end........................"

# start spark
echo "start spark begin....................."
#docker exec -t hadoop-master /bin/bash -c "export SPARK_MASTER_HOST=localhost && /root/spark-3.0.2-bin-hadoop2.7-hive1.2/sbin/start-all.sh"
${DOCKER_COMMAND} "export SPARK_MASTER_HOST=localhost && /root/spark-3.0.2-bin-hadoop2.7-hive1.2/sbin/start-all.sh"
if [ $? -ne 0 ]; then
    echo "fialed when executing export SPARK_MASTER_HOST=localhost && /root/spark-3.0.2-bin-hadoop2.7-hive1.2/sbin/start-all.sh"
    exit 1;
fi
echo "start spark end......................."

# start hbase
echo "start hbase begin....................."
${DOCKER_COMMAND} "/root/hbase-1.4.13/bin/start-hbase.sh"
if [ $? -ne 0 ]; then
    echo "fialed when executing /root/hbase-1.4.13/bin/start-hbase.sh"
    exit 1;
fi
echo "start hbase end........................"

# start kylin
echo "start hdfs mkdir for kylin begin......"
${DOCKER_COMMAND} "hadoop fs -mkdir /kylin"
if [ $? -ne 0 ]; then
    echo "fialed when executing "
    exit 1;
fi
${DOCKER_COMMAND} "hadoop fs -chown -R root:root /kylin"
if [ $? -ne 0 ]; then
    echo "fialed when executing hadoop fs -chown -R root:root /kylin"
    exit 1;
fi
echo "start hdfs mkdir for kylin end........"
echo "start kylin begin....................."
${DOCKER_COMMAND} "/root/apache-kylin-3.1.2-bin-hbase1x/bin/check-env.sh"
if [ $? -ne 0 ]; then
    echo "fialed when executing /root/apache-kylin-3.1.2-bin-hbase1x/bin/check-env.sh"
    exit 1;
fi
echo "check-env.sh success............................."
${DOCKER_COMMAND} "/root/apache-kylin-3.1.2-bin-hbase1x/bin/kylin.sh start"
if [ $? -ne 0 ]; then
    echo "fialed when executing /root/apache-kylin-3.1.2-bin-hbase1x/bin/kylin.sh start"
    exit 1;
fi
echo "start kylin end......................."

# start superset
echo "start superset db upgrade begin......."
${DOCKER_COMMAND} "superset db upgrade"
if [ $? -ne 0 ]; then
    echo "fialed when executing uperset db upgrade
    exit 1;
fi
echo "start superset db upgrade end........."
echo "start superset fab create-admin begin."
${DOCKER_COMMAND} "superset fab create-admin"
if [ $? -ne 0 ]; then
    echo "fialed when executing superset fab create-admin"
    exit 1;
fi
echo "start superset fab create-admin end..."
echo "start superset init begin............."
${DOCKER_COMMAND} "superset init"
if [ $? -ne 0 ]; then
    echo "fialed when executing superset init"
    exit 1;
fi
echo "start superset init end..............."
echo "start superset run begin.............."
${DOCKER_COMMAND} "nohup superset run -h 0.0.0.0 -p 8089 --with-threads --reload --debugger >superset.log 2>&1 &"
if [ $? -ne 0 ]; then
    echo "fialed when executing nohup superset run -h 0.0.0.0 -p 8089 --with-threads --reload --debugger >superset.log 2>&1 &"
    exit 1;
fi
echo "start superset run end................"
