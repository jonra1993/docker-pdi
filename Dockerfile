FROM openjdk:8-stretch
MAINTAINER Andre Pereira andrespp@gmail.com

# Set Environment Variables
ENV PDI_VERSION=9.2 PDI_BUILD=9.2.0.0-290 \
	PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/data-integration \
	KETTLE_HOME=/data-integration

RUN apt update && \	
    apt install -y ca-certificates xauth libwebkitgtk-1.0-0 wget libxrender1 libxtst6 libxi6

RUN update-ca-certificates

# Download PDI
RUN wget --no-check-certificate --progress=dot:giga https://razaoinfo.dl.sourceforge.net/project/pentaho/Pentaho-${PDI_VERSION}/client-tools/pdi-ce-${PDI_BUILD}.zip \
#RUN wget --progress=dot:giga http://downloads.sourceforge.net/project/pentaho/Data%20Integration/${PDI_VERSION}/pdi-ce-${PDI_BUILD}.zip \
	&& unzip -q *.zip \
	&& rm -f *.zip \
	&& mkdir /jobs

# Aditional Drivers
WORKDIR $KETTLE_HOME

RUN wget --no-check-certificate https://downloads.sourceforge.net/project/jtds/jtds/1.3.1/jtds-1.3.1-dist.zip \
	&& unzip jtds-1.3.1-dist.zip -d lib/ \
	&& rm jtds-1.3.1-dist.zip \
	&& wget --no-check-certificate https://github.com/FirebirdSQL/jaybird/releases/download/v3.0.4/Jaybird-3.0.4-JDK_1.8.zip \
	&& unzip Jaybird-3.0.4-JDK_1.8.zip -d lib \
	&& rm -rf lib/docs/ Jaybird-3.0.4-JDK_1.8.zip

# First time run
RUN pan.sh -file ./plugins/platform-utils-plugin/samples/showPlatformVersion.ktr \
	&& kitchen.sh -file samples/transformations/files/test-job.kjb

#VOLUME /jobs

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
