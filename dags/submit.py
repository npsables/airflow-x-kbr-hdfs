from pyspark.conf import SparkConf
from pyspark.sql import SparkSession
import time

def main(spark):
    df = spark.sql("""show databases""")
    df.show(100)
    time.sleep(20)

if __name__ == "__main__":
    start = time.time()

    conf = SparkConf().setAll([
                ("spark.executor.instances", 2),
                ("spark.executor.cores", 2),
                ("spark.executor.memory", "2g"),
                ("spark.driver.memory", "2g"),
                ("spark.dynamicAllocation.enabled", "false"),
                ("spark.sql.sources.partitionOverwriteMode", "dynamic"),
                ("hive.exec.dynamic.partition.mode", "nonstrict"),
                ]
            )

    global spark
    spark = (SparkSession
            .builder
            .appName('test_airflow_submitting') 
            .enableHiveSupport()
            .config(conf=conf)
            .getOrCreate())
    
    main(spark)
    print('Took {} secs'.format(time.time()-start))
