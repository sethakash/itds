
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

export SPARK_MAJOR_VERSION=2

fn_run_java ${MODULE_HOME}/lib/xml-avro-1.0.0-SNAPSHOT.jar com.exadatum.gobblin.XsdToAvsc ${MODULE_HOME}/etc/*.xsd

hadoop fs -mkdir -p ${META_DIR}/accounting

hadoop fs -copyFromLocal -f ${MODULE_HOME}/etc/*.avsc  ${META_DIR}/accounting/

fn_run_spark_transform_on_yarn transform.XmlToAvro \
    ${MODULE_HOME}/lib/accounting-transform.jar \
    ${MODULE_HOME}/lib/xml-avro-1.0.0-SNAPSHOT.jar \
    ${MODULE_HOME}/etc/accounting.xsd \
    ${DB_RAW_DIR}/accounting/batch_id=${BATCH_ID} \
    ${DB_TRANSFER_DIR}/accounting/batch_id=${BATCH_ID} \
    accounting.xsd

fn_run_hive "${MODULE_HOME}" \
    "${MODULE_HOME}/etc/hive/accounting-transform.hive.properties" \
    "${MODULE_HOME}/etc/schema/accounting-transform.hql"


###############################################################################
#                                     End                                     #
###############################################################################

