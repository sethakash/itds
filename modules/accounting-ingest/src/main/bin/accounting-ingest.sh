
#!/bin/bash
###############################################################################
#                               Documentation                                 #
###############################################################################
#                                                                             #
# Description                                                                 #
#     :                                                                       #
#                                                                             #
#                                                                             #
#                                                                             #
###############################################################################
#                           Identify Script Home                              #
###############################################################################

#Find the script file home
pushd . > /dev/null
SCRIPT_DIRECTORY="${BASH_SOURCE[0]}";
while([ -h "${SCRIPT_DIRECTORY}" ]);
do
  cd "`dirname "${SCRIPT_DIRECTORY}"`"
  SCRIPT_DIRECTORY="$(readlink "`basename "${SCRIPT_DIRECTORY}"`")";
done
cd "`dirname "${SCRIPT_DIRECTORY}"`" > /dev/null
SCRIPT_DIRECTORY="`pwd`";
popd  > /dev/null
MODULE_HOME="`dirname "${SCRIPT_DIRECTORY}"`"

###############################################################################
#                           Import Dependencies                               #
###############################################################################

if [ "${CONFIG_HOME}" == "" ]
then

     PROJECT_HOME="`dirname "${MODULE_HOME}"`"
     CONFIG_HOME="${PROJECT_HOME}/config"

fi

. ${CONFIG_HOME}/bash-env.properties
. ${MODULE_HOME}/bin/constants.sh
. ${MODULE_HOME}/bin/log-functions.sh
. ${MODULE_HOME}/bin/common-functions.sh
. ${MODULE_HOME}/bin/hadoop-functions.sh
. ${MODULE_HOME}/bin/itds-functions.sh


###############################################################################
#                                Main                                         #
###############################################################################


fn_get_persisted_batch_id

export CAMUS_HOME="${PROJECT_HOME}/custom-camus/"

fn_run_custom_camus "${MODULE_HOME}/etc/camus/accounting-ingest.properties"

hadoop fs -mkdir -p "${DB_RAW_DIR}/accounting/batch_id=${BATCH_ID}/"

fn_hadoop_move_file "${META_DIR}/topics/accounting/hourly/*/*/*/*/*" "${DB_RAW_DIR}/accounting/batch_id=${BATCH_ID}/"

fn_delete_hdfs_directory "${META_DIR}/topics/accounting"

fn_run_hive \
	"${MODULE_HOME}" \
    "${MODULE_HOME}/etc/hive/accounting-ingest.hive.properties" \
    "${MODULE_HOME}/etc/schema/accounting-ingest.hql"


###############################################################################
#                                     End                                     #
###############################################################################

