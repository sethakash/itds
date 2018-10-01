
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


DROP TABLE
  IF EXISTS
    ${DB_RAW}.raw_item
;

CREATE EXTERNAL TABLE ${DB_RAW}.raw_item
  PARTITIONED BY(
    batch_id  BIGINT
  )
  ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
  STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat'
  OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat'
  LOCATION '${DB_TRANSFER_DIR}/item/'
  TBLPROPERTIES ('avro.schema.url'='${META_DIR}/item/${tvar_avro_schema}')
;



USE ${DB_RAW}
;

MSCK REPAIR TABLE raw_item
;



--###############################################################################
--#                                     End                                     #
--###############################################################################

