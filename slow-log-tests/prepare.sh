#!/bin/bash

# $1 -> table size
# $2 -> table count
# $3 -> sandbox port
# $4 -> prefix

TBL_SIZE=$1
TBL_COUNT=$2
SANDBOX_PORT=$3
PREFIX=$4

WORKING_SANDBOX_DIR=~/sandboxes/msb_slow_log_${PREFIX}_5_7_17
CONTAINER_NAME=agustin-${PREFIX}-slow-log-sysbench
OUTPUT_DIR=$WORKING_SANDBOX_DIR/slow-log-outputs/
OUTPUT_FILE=$(date +%F-%T | tr ':-' '_')_ls_prepare

cat <<EOT >${WORKING_SANDBOX_DIR}/reset_slow_log.sh
#!/bin/bash

# this script should be added to:
# ~/sandboxes/msb_slow_log_my_5_7_17
# ~/sandboxes/msb_slow_log_ps_5_7_17

./use -e "SET GLOBAL slow_query_log=0"
rm data/bm-support01-slow.log
./use -e "SET GLOBAL slow_query_log=1"
EOT

chmod +x ${WORKING_SANDBOX_DIR}/reset_slow_log.sh

cd $WORKING_SANDBOX_DIR

./use -e "DROP SCHEMA test; CREATE SCHEMA test;"
./reset_slow_log.sh

echo RUNNING DOCKER sysbench prepare...
sudo docker rm -v ${CONTAINER_NAME}

sudo docker run --rm --name ${CONTAINER_NAME} \
--network=host \
-e MYSQL_HOST=127.0.0.1 \
-e MYSQL_PASS="msandbox" \
-e MYSQL_PORT=${SANDBOX_PORT} \
-e OLTP_TABLE_SIZE=${TBL_SIZE} \
-e OLTP_TABLES_COUNT=${TBL_COUNT} \
-e NO_RUN=1 \
guriandoro/sysbench:0.5-6.3 bash

if [ ! -d $OUTPUT_DIR ]; then
  mkdir $OUTPUT_DIR
fi

ls -l ${WORKING_SANDBOX_DIR}/data/bm-support01-slow.log >> ${OUTPUT_DIR}/${OUTPUT_FILE}
ls -lh ${WORKING_SANDBOX_DIR}/data/bm-support01-slow.log >> ${OUTPUT_DIR}/${OUTPUT_FILE}

exit
