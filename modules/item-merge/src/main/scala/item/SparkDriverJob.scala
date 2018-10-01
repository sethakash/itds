import java.io.File

import org.apache.spark.sql.SparkSession
import com.typesafe.config.ConfigFactory


object MergeDriverJob {

  def main(args:Array[String]){

    println("Starting The Spark Driver For Merge Job ")

       /**
      * Load the Table Details From Config
      */

    lazy val sessionBuilder=new SessionBuilder(new File(args(0)))

    lazy val tableParser=new TableParser(sessionBuilder)

    val source_table_name=sessionBuilder
                          .loadConfiguration("sourceTable")

    val current_table_name=sessionBuilder
                          .loadConfiguration("currentTable")
    val history_table_name=sessionBuilder
                            .loadConfiguration("historyTable")
    val primary_key=sessionBuilder
                            .loadConfiguration("primaryKey")

    val spark=sessionBuilder.getSparkSession

    val batch_id=args(1)

    /**
      * Load Source Data
      */
    val source_table=tableParser
                     .loadTable(source_table_name)

      /**
      * Load Current Data
      */
    val current_table=tableParser
                        .loadTable(current_table_name)

      /**
      * Load History Data
      */
    val history_table=tableParser
                          .loadTable(history_table_name)

      /**
      * Create a Join Expression
      */
    val joinExpression = current_table
                              .col(s"$primary_key") ===
                          source_table.col(s"$primary_key")

    val joined_records = current_table.as("C")
                          .join(source_table.as("S"),
                          joinExpression,"full_outer")


    /**
      * Fetch Updated Data
      */
    val updatedData=joined_records
                  .filter(s"S.$primary_key" +
                    s" is not null and C.$primary_key is not null")
                    .select("S.*")

    /**
      * Fetch New Data
      */
    val newData=joined_records
                .filter(s"S.$primary_key " +
                  s"is not null and C.$primary_key is null")
                  .select("S.*")

    /**
      * Fetch Deleted Data in Current Snapshot
      */
    val deletedData=joined_records
                .filter(s"C.$primary_key" +
                  s" is not null and S.$primary_key is null")
                 .select("C.*")


    /**
      * Fetch Old Data from Current Snapshot,the Data that has changed need to be
      * pushed to History Table
      */
    val oldData=joined_records
                .filter(s"S.$primary_key" +
                  s" is not null and C.$primary_key is not null")
                 .select("C.*")

      /**
      * Merge Updated and New Data
      */
      val merge_updated_new_record=updatedData
                                  .union(newData)
                                  .union(deletedData).drop("batch_id")

    /**
      * Merge Old and History Data and Push to History Table
      */
    val merge_historical_data=history_table
                              .union(oldData).drop("batch_id")


    /**
      * Register View For Loading To Current Table
      */
    merge_updated_new_record
      .createTempView("updated_snapshot_table")

    /**
      * Register View for Loading To History Table
      */
    merge_historical_data
      .createTempView("history_snapshot_table")


      spark.sql(s" SET hive.exec.dynamic.partition=true;SET hive.exec.dynamic.partition.mode=nonstrict;" +
                  s"insert overwrite table " +
                  s" $history_table_name partition(batch_id)" +
                  s" select * from history_snapshot_table ")

      spark.sql(s" SET hive.exec.dynamic.partition=true;SET hive.exec.dynamic.partition.mode=nonstrict;" +
            s"insert overwrite table" +
            s" $current_table_name partition(batch_id)" +
            s" select * from updated_snapshot_table")

}

}
