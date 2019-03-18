DROP TABLE IF EXISTS rawlogs;
DROP TABLE IF EXISTS logsummary;

CREATE EXTERNAL TABLE rawlogs
(log_date DATE,
 log_time STRING,
 c_ip STRING,
 cs_username STRING,
 s_ip STRING,
 s_port STRING,
 cs_method STRING,
 cs_uri_stem STRING,
 cs_uri_query STRING,
 sc_status STRING,
 sc_bytes INT,
 cs_bytes INT,
 time_taken INT,
 cs_user_agent STRING,
 cs_referrer STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ' '
STORED AS TEXTFILE LOCATION '${hiveconf:log_folder}/${hiveconf:year}/${hiveconf:month}/'
tblproperties ("skip.header.line.count"="4");

CREATE EXTERNAL TABLE logsummary
  (log_date DATE,
   requests INT,
   bytes_in FLOAT,
   bytes_out FLOAT)
PARTITIONED BY (year INT, month INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE LOCATION '${hiveconf:summary_folder}';

INSERT OVERWRITE TABLE logsummary PARTITION(year, month)
SELECT log_date,
       COUNT(*) AS requests,
       SUM(cs_bytes) AS inbound_bytes,
       SUM(sc_bytes) AS outbound_bytes,
       YEAR(log_date),
       MONTH(log_date)
FROM rawlogs
GROUP BY log_date;