FROM centos:latest

RUN mkdir /app && cd /app \
&& yum update -y \
&& yum install -y \
  langpacks-en \
  glibc-all-langpacks \
  gcc \
  libnsl \
  bzip2 \
  postgresql \
  wget \
&& wget https://download.oracle.com/otn_software/linux/instantclient/19800/oracle-instantclient19.8-basic-19.8.0.0.0-1.x86_64.rpm \
&& wget https://download.oracle.com/otn_software/linux/instantclient/19800/oracle-instantclient19.8-sqlplus-19.8.0.0.0-1.x86_64.rpm \
&& wget https://download.oracle.com/otn_software/linux/instantclient/19800/oracle-instantclient19.8-tools-19.8.0.0.0-1.x86_64.rpm \
&& wget https://download.oracle.com/otn_software/linux/instantclient/19800/oracle-instantclient19.8-devel-19.8.0.0.0-1.x86_64.rpm \
&& wget https://download.oracle.com/otn_software/linux/instantclient/19800/oracle-instantclient19.8-jdbc-19.8.0.0.0-1.x86_64.rpm \
&& wget https://download.oracle.com/otn_software/linux/instantclient/19800/oracle-instantclient19.8-odbc-19.8.0.0.0-1.x86_64.rpm \
&& yum install -y *.rpm \
&& export ORACLE_HOME=/usr/lib/oracle/19.8/client64/lib \
&& export LD_LIBRARY_PATH=$ORACLE_HOME \
&& yum install -y \
  perl \
  perl-DBI \
  perl-DBD-Pg \
  perl-DBD-MySQL \
  perl-DBD-SQLite \
&& wget https://github.com/darold/ora2pg/archive/v20.0.tar.gz \
&& tar -xzf v20.0.tar.gz && cd ora2pg-20.0 \
&& perl Makefile.PL && make && make install \
&& export PERL_MM_USE_DEFAULT=1 \
&& perl -MCPAN -e 'install DBD::Oracle' \
&& yum clean all \
&& cd / && rm -rf /app

CMD ["ora2pg","--help"]
