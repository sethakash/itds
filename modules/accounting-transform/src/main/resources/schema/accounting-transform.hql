
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
    ${DB_TRANS}.trans_accounting
;

CREATE EXTERNAL TABLE ${DB_TRANS}.trans_accounting
  PARTITIONED BY(
    batch_id  BIGINT
  )
  ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.avro.AvroSerDe'
  STORED AS INPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerInputFormat'
  OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.avro.AvroContainerOutputFormat'
  LOCATION '${DB_TRANSFER_DIR}/accounting/'
  TBLPROPERTIES ('avro.schema.url'='${META_DIR}/accounting/accounting.avsc')
;



USE ${DB_TRANS}
;

MSCK REPAIR TABLE trans_accounting
;



--###############################################################################
--#                                     End                                     #
--###############################################################################

