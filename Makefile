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

package:
	mvn clean package

run: package
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

updates:
	mvn versions:display-dependency-updates
	mvn versions:display-plugin-updates

build-source-jar:
	wget -O $(HADOOP_FILE) http://apache.cs.uu.nl/dist/hadoop/common/hadoop-$(HADOOP_VERSION)/hadoop-$(HADOOP_VERSION).tar.gz
	tar -xzvf $(HADOOP_FILE) -C /tmp
	rm -f $(HADOOP_OUTPUT)
	rm -f $(HADOOP_MANIFEST)

	echo "Manifest-Version: 1.0" > $(HADOOP_MANIFEST)
	echo "Bundle-ManifestVersion: 2" >> $(HADOOP_MANIFEST)
	echo "Bundle-Name: Hadoop $(HADOOP_VERSION) sources" >> $(HADOOP_MANIFEST)
	jar -cvfm $(HADOOP_OUTPUT) $(HADOOP_MANIFEST)
	cd $(HADOOP_SRC)/core/ && jar -uvf $(HADOOP_OUTPUT) *
	cd $(HADOOP_SRC)/hdfs/ && jar -uvf $(HADOOP_OUTPUT) *
	cd $(HADOOP_SRC)/mapred/ && jar -uvf $(HADOOP_OUTPUT) *

	mvn install:install-file \
    -Dfile=$(HADOOP_OUTPUT) \
    -DgroupId=org.apache.hadoop \
    -DartifactId=hadoop-core \
    -Dversion=$(HADOOP_VERSION) \
    -Dpackaging=jar \
    -DgeneratePom=false \
    -Dclassifier=sources