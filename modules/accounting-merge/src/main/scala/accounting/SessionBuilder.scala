import java.io.File

import org.apache.spark.sql.SparkSession
import com.typesafe.config.ConfigFactory


/**
  * Retuns a Spark Session
  */
class SessionBuilder(file:File) {


  lazy val value =ConfigFactory.parseFile(file)

  /**
    * Creates or Returns a Spark Session
    * @return
    */
  def getSparkSession:SparkSession={
     val spark=SparkSession
      .builder()
       .appName("Merge Controller")
       .master(loadConfiguration("masterHostname"))
       .enableHiveSupport()
       .config("spark.sql.warehouse.dir",loadConfiguration("warehouseLocation"))
       .config("hive.metastore.warehouse.dir",loadConfiguration("warehouseLocation"))
       .config("hive.exec.dynamic.partition", loadConfiguration("dynamicPartitionFlag"))
       .config("hive.exec.dynamic.partition.mode", loadConfiguration("dynamicPartitionMode"))
       .getOrCreate()
    return spark
  }

  /**
    * Load the Configuration and Return a Map of Table Details
    * @return
    */
  def loadConfiguration:scala.collection.mutable.Map[String,String]={
    var configuration=scala.collection.mutable.Map[String, String]()
    configuration+=("sourceTable"->value.getString("application.tabledetails.source_table_name"))
    configuration+=("currentTable"->value.getString("application.tabledetails.current_table_name"))
    configuration+=("historyTable"->value.getString("application.tabledetails.history_table_name"))
    configuration+=("primaryKey"->value.getString("application.tabledetails.primary_key"))
    configuration+=("partitionCol"->value.getString("application.tabledetails.partitionCol"))
    configuration+=("partitionValue"->value.getString("application.tabledetails.partitionValue"))
    configuration+=("masterHostname"->value.getString("application.driver.master_hostname"))
    configuration+=("warehouseLocation"->value.getString("application.driver.warehouse_location"))
    configuration+=("dynamicPartitionFlag"->value.getString("application.driver.dynamicPartitionFlag"))
    configuration+=("dynamicPartitionMode"->value.getString("application.driver.dynamicPartitionMode"))
    return configuration
  }


}
