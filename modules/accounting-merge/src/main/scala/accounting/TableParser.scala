import org.apache.spark.sql.{DataFrame, SparkSession}


/**
  * Reads Hive Tables
  */
class TableParser(sessionBuilder:SessionBuilder) {


  val spark=sessionBuilder.getSparkSession

  /**
    * Returns A DataFrame
    * @param tableName
    * @return
    */

  def loadTable(tableName:String):DataFrame=
  {
    val rows=spark
            .sql(s"select * from $tableName")
    return rows;
  }

}