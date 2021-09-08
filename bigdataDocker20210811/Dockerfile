FROM centos:7

# install ssl
RUN yum install -y openssh-server sudo
#RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN yum  install -y openssh-clients && \
    echo "root:123456" | chpasswd && \
    echo "root   ALL=(ALL)       ALL" >> /etc/sudoers
#RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN ssh-keygen -t rsa -P '' -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -t ecdsa -P '' -f /etc/ssh/ssh_host_ecdsa_key && \
    ssh-keygen -t ed25519 -P '' -f /etc/ssh/ssh_host_ed25519_key
#RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN cat /etc/ssh/ssh_host_rsa_key.pub  >> /etc/ssh/authorized_keys && \
    mkdir /var/run/sshd
EXPOSE 22

# install wget
RUN yum install -y wget which sudo

#USER root root 

# install jdk
ADD jdk-8u281-linux-x64.tar.gz /usr/local/java/
ENV JAVA_HOME /usr/local/java/jdk1.8.0_281
ENV JRE_HOME /usr/local/java/jdk1.8.0_281/jre 
ENV CLASSPATH .:$CLASSPATH:$JAVA_HOME/lib:$JRE_HOME/lib
ENV PATH $PATH:$JAVA_HOME/bin:$JRE_HOME/bin
 
WORKDIR /root

# install hadoop
#RUN wget https://www.apache.org/dyn/closer.cgi/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz 
#RUN tar -xvf hadoop-2.10.1.tar.gz
ADD hadoop-2.10.1.tar.gz /root
RUN sed -i 's/export JAVA_HOME=${JAVA_HOME}/export JAVA_HOME=\/usr\/local\/java\/jdk1.8.0_281/g' /root/hadoop-2.10.1/etc/hadoop/hadoop-env.sh
ENV HADOOP_HOME /root/hadoop-2.10.1 
ENV PATH $PATH:$HADOOP_HOME/bin
#RUN hadoop namenode -format && /root/hadoop-2.10.1/sbin/start-all.sh && /root/hadoop-2.10.1/sbin/mr-jobhistory-daemon.sh start historyserver
 
# install hive, NOTE: optional on worker node
#RUN wget https://archive.apache.org/dist/hive/hive-1.2.1/apache-hive-1.2.1-bin.tar.gz
#RUN tar -xvf apache-hive-1.2.1-bin.tar.gz
ADD apache-hive-1.2.1-bin.tar.gz /root
ENV HIVE_HOME /root/apache-hive-1.2.1-bin
ENV PATH $PATH:$HIVE_HOME/bin
#RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.43/mysql-connector-java-5.1.43.jar
#RUN cp mysql-connector-java-5.1.43-bin.jar /root/apache-hive-1.2.1-bin/lib/
ADD mysql-connector-java-5.1.43-bin.jar /root/apache-hive-1.2.1-bin/lib/

# install spark
#RUN wget https://archive.apache.org/dist/spark/spark-3.0.2/spark-3.0.2-bin-hadoop2.7-hive1.2.tgz
#RUN tar -xvf spark-3.0.2-bin-hadoop2.7-hive1.2.tgz
ADD spark-3.0.2-bin-hadoop2.7-hive1.2.tgz /root
RUN cp spark-3.0.2-bin-hadoop2.7-hive1.2/conf/spark-env.sh.template spark-3.0.2-bin-hadoop2.7-hive1.2/conf/spark-env.sh && \
    echo echo 'export JAVA_HOME="/usr/local/java/jdk1.8.0_281"' >> /root/spark-3.0.2-bin-hadoop2.7-hive1.2/sbin/spark-config.sh
ENV SPARK_HOME /root/spark-3.0.2-bin-hadoop2.7-hive1.2
ENV PATH $PATH:$SPARK_HOME/bin
ENV LD_LIBRARY_PATH $HADOOP_HOME/lib/native/:$LD_LIBRARY_PATH
ENV SPARK_EXECUTOR_MEMORY 1G

# install hbase
#RUN wget https://mirrors.bfsu.edu.cn/apache/hbase/1.4.13/hbase-1.4.13-bin.tar.gz
#RUN tar -xvf hbase-1.4.13-bin.tar.gz
ADD hbase-1.4.13-bin.tar.gz /root
RUN sed -i '/CLASSPATH=${CLASSPATH}:$JAVA_HOME\/lib\/tools.jar/a CLASSPATH=$HBASE_HOME\/lib\/*' /root/hbase-1.4.13/bin/hbase && \
    sed -i 's/# export HBASE_MANAGES_ZK=true/export HBASE_MANAGES_ZK=true/g' /root/hbase-1.4.13/conf/hbase-env.sh
ENV HBASE_HOME /root/hbase-1.4.13
ENV PATH $PATH:$HBASE_HOME/bin
#ENV HBASE_MANAGES_ZK true

# install kylin
#RUN wget https://archive.apache.org/dist/kylin/apache-kylin-3.1.2/apache-kylin-3.1.2-bin-hbase1x.tar.gz
#RUN tar -xvf apache-kylin-3.1.2-bin-hbase1x.tar.gz
ADD apache-kylin-3.1.2-bin-hbase1x.tar.gz /root
RUN echo "kylin.env.hdfs-working-dir=/kylin" >> /root/apache-kylin-3.1.2-bin-hbase1x/conf/kylin.properties && \
    sed  -i '21a export HBASE_CLASSPATH_PREFIX=${tomcat_root}/bin/bootstrap.jar:${tomcat_root}/bin/tomcat-juli.jar:${tomcat_root}/lib/*:$hive_dependency:$HBASE_CLASSPATH_PREFIX' /root/apache-kylin-3.1.2-bin-hbase1x/bin/kylin.sh && \
    sed  -i '208c hive_lib=`find -L ${hive_lib_dir} -name '*.jar' ! -name '*druid*' ! -name '*jackson*' ! -name '*slf4j*' ! -name '*avatica*' ! -name '*calcite*' ! -name '*jackson-datatype-joda*' ! -name '*derby*' -printf '%p:' | sed 's/:$//'`' /root/apache-kylin-3.1.2-bin-hbase1x/bin/find-hive-dependency.sh && \
    sed  -i '70c spark_dependency=`find -L ${spark_home}/jars -name '*.jar' ! -name '*jackson*' ! -name '*slf4j*' ! -name '*calcite*' ! -name '*doc*' ! -name '*test*' ! -name '*sources*' ''-printf '%p:' | sed 's/:$//'`' /root/apache-kylin-3.1.2-bin-hbase1x/bin/find-spark-dependency.sh
ENV KYLIN_HOME /root/apache-kylin-3.1.2-bin-hbase1x
ENV KYLIN_CONF /root/apache-kylin-3.1.2-bin-hbase1x/conf
ENV tomcat_root $KYLIN_HOME/tomcat
ENV HBASE_CLASSPATH_PREFIX ${tomcat_root}/bin/bootstrap.jar:${tomcat_root}/bin/tomcat-juli.jar:${tomcat_root}/lib/*:$hive_dependency:$HBASE_CLASSPATH_PREFIX

# install superset
RUN yum install -y gcc gcc-c++ make libffi-devel python-devel python-pip python-wheel openssl-devel cyrus-sasl-devel openldap-devel zlib-devel bzip2-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
ADD Python-3.7.9.tgz /root
WORKDIR /root/Python-3.7.9
RUN ./configure && make && make install && \
    pip3 uninstall flask-wtf && \
    pip3 install flask-wtf===0.14.3 && \
    pip3 install apache-superset && \
    pip3 install --upgrade kylinpy
ENV FLASK_APP superset
#RUN superset db upgrade
#RUN superset fab create-admin
#RUN superset load_examples
#RUN superset init
#RUN superset run -h 0.0.0.0 -p 8089 --with-threads --reload --debugger
WORKDIR /root

CMD ["/usr/sbin/sshd", "-D"]
