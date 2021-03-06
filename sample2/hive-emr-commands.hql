add jar /home/hadoop/gis-tools/lib/esri-geometry-api-1.1.1.jar;
add jar /home/hadoop/gis-tools/lib/spatial-sdk-hive-1.0.1.jar;
add jar /home/hadoop/gis-tools/lib/spatial-sdk-json-1.0.1.jar;

create temporary function ST_Point as 'com.esri.hadoop.hive.ST_Point';
create temporary function ST_Contains as 'com.esri.hadoop.hive.ST_Contains';

DROP TABLE earthquakes;
CREATE EXTERNAL TABLE earthquakes (earthquake_date STRING, latitude DOUBLE, longitude DOUBLE, magnitude DOUBLE)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION 's3://marwa.gishadoop.com/sample/data/earthquake-data';



DROP TABLE counties;
CREATE EXTERNAL TABLE counties (Area string, Perimeter string, State string, County string, Name string, BoundaryShape binary)
ROW FORMAT SERDE 'com.esri.hadoop.hive.serde.JsonSerde'
STORED AS INPUTFORMAT 'com.esri.json.hadoop.EnclosedJsonInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION 's3://marwa.gishadoop.com/sample/data/counties-data';

INSERT OVERWRITE DIRECTORY '${OUTPUT}'
SELECT counties.name, count(*) cnt FROM counties
JOIN earthquakes
WHERE ST_Contains(counties.boundaryshape, ST_Point(earthquakes.longitude, earthquakes.latitude))
GROUP BY counties.name
ORDER BY cnt desc;
