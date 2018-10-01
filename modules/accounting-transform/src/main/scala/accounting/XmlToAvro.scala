package transform

import java.io.{ByteArrayOutputStream, File, IOException}

import com.exadatum.gobblin.{DatumBuilder, SchemaBuilder}
import org.apache.avro.generic.{GenericData, GenericDatumReader, GenericDatumWriter, GenericRecord}
import org.apache.avro.io.{DecoderFactory, EncoderFactory}
import org.apache.avro.mapred.AvroKey
import org.apache.avro.mapreduce.AvroKeyOutputFormat
import org.apache.spark.{SparkContext, SparkFiles}
import org.apache.spark.rdd.RDD
import org.apache.spark.sql.{Dataset, SparkSession}

object XmlToAvro {

  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder().appName("XML to AVRO")
      .getOrCreate()


    val xmlFrame = spark.sparkContext.textFile(args(0)+"/*")
    val avroDataset = xmlFrame.map(row => {
      val xmlRecord = row
      val schemaBuilder = new SchemaBuilder
      val schema = schemaBuilder.createSchema(new File(args(2)))
      val datumBuilder = new DatumBuilder(schema)
      val datum:Object = datumBuilder.createDatum(xmlRecord)
      val output = new ByteArrayOutputStream
      try {
        val stream = output
        try {
          val datumWriter = new GenericDatumWriter[AnyRef](schema)
          datumWriter.write(datum, EncoderFactory.get.directBinaryEncoder(stream, null))
        } catch {
          case e: IOException =>
            e.printStackTrace()
        } finally if (stream != null) stream.close()
      }

      val decoder = DecoderFactory.get.binaryDecoder(output.toByteArray, null)
      val recordReader = new GenericDatumReader[GenericData.Record](schema)
      val parsedRecord = recordReader.read(null, decoder)
      parsedRecord
    }
    )

    saveAvroRDD(args(1),avroDataset.toJavaRDD,spark.sparkContext,args(3))
  }

  def saveAvroRDD(avroFileLocation: String, parsedXMLRDD: RDD[GenericData.Record], sc : SparkContext,xsd:String): Int = {
    try {
      val job = org.apache.hadoop.mapreduce.Job.getInstance()
      job.setOutputKeyClass(classOf[AvroKey[GenericRecord]])
      job.getConfiguration.set("mapreduce.output.fileoutputformat.compress", "true")
      //job.getConfiguration.set("mapreduce.output.fileoutputformat.compress.codec",
      //  "org.apache.hadoop.io.compress.SnappyCodec")
      job.getConfiguration.set("mapreduce.output.fileoutputformat.outputdir", avroFileLocation)
      org.apache.avro.mapreduce.AvroJob.setOutputKeySchema(job,new SchemaBuilder().createSchema(new File(xsd)))
      job.setOutputFormatClass(classOf[AvroKeyOutputFormat[GenericRecord]])

      parsedXMLRDD.map(elem => {
        (new AvroKey(elem), null)
      }).saveAsNewAPIHadoopDataset(job.getConfiguration)
      0
    } catch {
      case ex: Throwable => {
        ex.printStackTrace
        -1
      }
    }
  }

}