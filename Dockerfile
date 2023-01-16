# Better use base image of airflow
FROM apache/airflow:2.5.0
ENV DEBIAN_FRONTEND=noninteractive
USER root

# java and apt
RUN apt-get update && apt-get install software-properties-common -y
RUN add-apt-repository 'deb http://security.debian.org/debian-security stretch/updates main' \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        openjdk-8-jdk \
        krb5-user \
        libpam-krb5 \
        libkrb5-dev \
        krb5-config \
        libssl-dev \
        libsasl2-dev \
        libsasl2-modules-gssapi-mit \
        krb5-auth-dialog \
        wget \
        curl \
        vim \
        telnet \
        build-essential\
        libopenmpi-dev \
        ldap-utils \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# kerberos
ENV KRB5_CONFIG=/etc/krb5.conf

# spark and hadoop connection
ARG HADOOP_VERSION=3.0.0
ARG SPARK_VERSION=2.4.2
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV HADOOP_INSTALL=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV YARN_HOME=$HADOOP_HOME
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV SPARK_HOME=/opt/spark

RUN mkdir -p "${HADOOP_HOME}" && chown -R airflow "${HADOOP_HOME}"
RUN mkdir -p "${SPARK_HOME}" && chown -R airflow "${SPARK_HOME}"
RUN ln -s "${HADOOP_HOME}/etc/hadoop" /etc/hadoop && chown -R airflow /etc/hadoop

RUN HADOOP_URL="https://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
    && curl 'https://dist.apache.org/repos/dist/release/hadoop/common/KEYS' | gpg --import - \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && curl -fSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc \
    && gpg --verify /tmp/hadoop.tar.gz.asc \
    && tar -xvf /tmp/hadoop.tar.gz -C "${HADOOP_HOME}" --strip-components=1 \
    && rm /tmp/hadoop.tar.gz /tmp/hadoop.tar.gz.asc 

ENV PATH="$HADOOP_HOME/bin/:$PATH"

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz && \
    tar -zxf ./spark-* -C /opt/spark --strip-components=1 && \
    rm spark-*.tgz 

ENV PATH="$SPARK_HOME/bin/:$PATH"
ENV SPARK_DIST_CLASSPATH=/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*

USER airflow
COPY ./airflow/webserver_config.py ${AIRFLOW_HOME}

# spark-submit --master yarn --conf spark.master=yarn --conf spark.submit.deployMode=client --conf spark.yarn.queue=test --conf spark.network.timeout=15000s --principal ${KERBEROS_PRINCIPAL} --keytab ${KERBEROS_KEYTAB_PATH} --name arrow-spark /opt/airflow/dags/submit.py
