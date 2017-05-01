#!/bin/bash

# $1 -> table size
# $2 -> table count
# $3 -> num threads
# $4 -> max time
# $5 -> sandbox port
# $6 -> prefix

TBL_SIZE=$1
TBL_COUNT=$2
NUM_THREADS=$3
MAX_TIME=$4
SANDBOX_PORT=$5
PREFIX=$6

CONTAINER_NAME="agustin-${PREFIX}-slow-log-sysbench"
WORKING_SANDBOX_DIR=~/sandboxes/msb_slow_log_${PREFIX}_5_7_17
OUTPUT_DIR=$WORKING_SANDBOX_DIR/slow-log-outputs/

echo REMOVING OLD CONTAINER, IF ANY...
sudo docker rm -v ${CONTAINER_NAME}

echo
echo RUNNING DOCKER sysbench run...

sudo docker run -d --name ${CONTAINER_NAME} \
--network=host \
-e MYSQL_HOST=127.0.0.1 \
-e MYSQL_PASS="msandbox" \
-e MYSQL_PORT=${SANDBOX_PORT} \
-e NUM_THREADS=${NUM_THREADS} \
-e MAX_TIME=${MAX_TIME} \
-e OLTP_TABLE_SIZE=${TBL_SIZE} \
-e OLTP_TABLES_COUNT=${TBL_COUNT} \
-e NO_PREPARE=1 \
guriandoro/sysbench:0.5-6.3 bash

echo
echo Some commands that may be useful:
echo
echo docker exec -it ${CONTAINER_NAME} /bin/bash
echo 
echo docker logs -f ${CONTAINER_NAME}
echo
echo "docker logs ${CONTAINER_NAME} | grep -A 30 'OLTP test statistics'"
echo
echo docker stop ${CONTAINER_NAME}
echo
echo SLEEPING FOR ${MAX_TIME}+10 SECONDS...
date

sleep $(($MAX_TIME + 10))

echo GETTING OUTPUTS FROM LOGS...

if [ ! -d $OUTPUT_DIR ]; then
  mkdir $OUTPUT_DIR
fi

OUTPUT_FILE=$(date +%F-%T | tr ':-' '_')_sysbench

sudo docker logs ${CONTAINER_NAME} | grep -A 30 'OLTP test statistics' >> ${OUTPUT_DIR}/${OUTPUT_FILE}

OUTPUT_FILE=$(date +%F-%T | tr ':-' '_')_ls_run

ls -l ${WORKING_SANDBOX_DIR}/data/bm-support01-slow.log >> ${OUTPUT_DIR}/${OUTPUT_FILE}
ls -lh ${WORKING_SANDBOX_DIR}/data/bm-support01-slow.log >> ${OUTPUT_DIR}/${OUTPUT_FILE}

exit
