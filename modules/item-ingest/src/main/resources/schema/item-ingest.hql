
--###############################################################################
--#                               Documentation                                 #
--###############################################################################
--#                                                                             #
--# Description                                                                 #
--#     :                                                                       #
--#                                                                             #
--#                                                                             #
--#                                                                             #
--#                                                                             #
--#                                                                             #
--#                                                                             #
--###############################################################################
--#                                  Script                                     #
--###############################################################################


ADD JAR  ${XSD_JAR_PATH};

DROP TABLE IF EXISTS
    ${DB_RAW}.raw_item;

CREATE EXTERNAL TABLE ${DB_RAW}.raw_item
PARTITIONED BY(
      batch_id  BIGINT
   )
ROW FORMAT SERDE 'com.exadatum.hive.xsd.serde.XmlXsdSerDe'
WITH SERDEPROPERTIES (
'schema.file.location'='${META_DIR}/xsd/item.xsd'
)
STORED AS
INPUTFORMAT 'com.exadatum.hive.xsd.serde.readerwriter.XmlInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat'
LOCATION '${DB_RAW_DIR}/item'
;

USE ${DB_RAW};

MSCK REPAIR TABLE raw_item;



--###############################################################################
--#                                     End                                     #
--###############################################################################

