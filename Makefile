HADOOP_VERSION := $(shell brew info hadoop | grep "hadoop:" | grep -o "[0-9].[0-9].[0-9]")
HADOOP_BIN := $(shell brew --prefix)/Cellar/hadoop/$(HADOOP_VERSION)/libexec/bin
HADOOP_FILE=/tmp/hadoop-$(HADOOP_VERSION).tar.gz
HADOOP_ROOT=/tmp/hadoop-$(HADOOP_VERSION)
HADOOP_SRC=$(HADOOP_ROOT)/src
HADOOP_MANIFEST=$(HADOOP_ROOT)/MANIFEST.MF
HADOOP_OUTPUT=$(HADOOP_ROOT)/hadoop-core-${HADOOP_VERSION}-sources.jar
PROJECT=gutenberg
PROJECT_INPUT=$(PROJECT)-input
PROJECT_OUTPUT=$(PROJECT)-output

fetch-data:
	cd src/main/data && ./fetch-data.sh

package:
	mvn clean package

run:
	hadoop jar target/*-job.jar $(PROJECT_INPUT) $(PROJECT_OUTPUT)

delete-input:
	hadoop fs -rmr $(PROJECT_INPUT)

delete-output:
	hadoop fs -rmr $(PROJECT_OUTPUT)

cat-output:
	hadoop fs -cat $(PROJECT_OUTPUT)/part-r-00000

prepare-input:
	hadoop fs -mkdir $(PROJECT_INPUT)
	hadoop fs -copyFromLocal src/main/data/*.txt $(PROJECT_INPUT)

start-cluster:
	$(HADOOP_BIN)/start-all.sh

stop-cluster:
	$(HADOOP_BIN)/stop-all.sh

format-hdfs:
	hadoop namenode -format-hdfs

open-namenode:
	open http://localhost:50070/

open-jobtracker:
	open http://localhost:50030/

open-tasktracker:
	open http://localhost:50060/
