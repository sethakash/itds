
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
    ${DB_RAW}.raw_accounting
;

CREATE EXTERNAL TABLE ${DB_RAW}.raw_accounting
  PARTITIONED BY(
    batch_id  BIGINT
  )
  ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
  STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat'
  OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat'
  LOCATION '${DB_TRANSFER_DIR}/accounting/'
  TBLPROPERTIES ('avro.schema.url'='${META_DIR}/accounting/${tvar_avro_schema}')
;



USE ${DB_RAW}
;

MSCK REPAIR TABLE raw_accounting
;



--###############################################################################
--#                                     End                                     #
--###############################################################################

