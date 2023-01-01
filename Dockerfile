# FROM ubuntu:18.04
FROM nexus3.o-ran-sc.org:10002/o-ran-sc/bldr-ubuntu18-c-go:1.9.0 as build-kpimon
WORKDIR /opt
# Install RMR client

# Ken Debug :  command COPY bin/rmr* ./ -> will cause COPY failed: no source files were specified
#COPY bin/rmr* ./
# Ken Debug : download rmr instead of COPY from a location
RUN wget -nv --content-disposition https://packagecloud.io/o-ran-sc/release/packages/debian/stretch/rmr_4.8.0_amd64.deb/download.deb
RUN wget -nv --content-disposition https://packagecloud.io/o-ran-sc/release/packages/debian/stretch/rmr-dev_4.8.0_amd64.deb/download.deb

# Ken Debug : dpkg rmr 
#RUN dpkg -i rmr_4.8.0_amd64.deb; dpkg -i rmr-dev_4.8.0_amd64.deb; rm rmr*
RUN dpkg -i rmr_4.8.0_amd64.deb; dpkg -i rmr-dev_4.8.0_amd64.deb; rm -rf rmr_4.8.0_amd64.deb; rm -rf rmr-dev_4.8.0_amd64.deb


RUN apt-get update && \
    apt-get -y install gcc
COPY e2ap/ e2ap/
COPY e2sm/ e2sm/
# "COMPILING E2AP Wrapper"
RUN cd e2ap && \
    gcc -c -fPIC -Iheaders/ lib/*.c wrapper.c && \
    gcc *.o -shared -o libe2apwrapper.so && \
    cp libe2apwrapper.so /usr/local/lib/ && \
    mkdir /usr/local/include/e2ap && \
    cp wrapper.h headers/*.h /usr/local/include/e2ap && \
    ldconfig

# "COMPILING E2SM Wrapper"
RUN cd e2sm && \
    gcc -c -fPIC -Iheaders/ lib/*.c wrapper.c && \
    gcc *.o -shared -o libe2smwrapper.so && \
    cp libe2smwrapper.so /usr/local/lib/ && \
    mkdir /usr/local/include/e2sm && \
    cp wrapper.h headers/*.h /usr/local/include/e2sm && \
    ldconfig
# Setup running environment
COPY control/ control/
COPY ./go.mod ./go.mod
COPY ./kpimon.go ./kpimon.go

RUN wget -nv --no-check-certificate https://dl.google.com/go/go1.18.linux-amd64.tar.gz \
     && tar -xf go1.18.linux-amd64.tar.gz \
     && rm -f go*.gz
ENV DEFAULTPATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PATH=$DEFAULTPATH:/usr/local/go/bin:/opt/go/bin:/root/go/bin
COPY go.sum go.sum

RUN go build ./kpimon.go

COPY config-file.yaml .
ENV CFG_FILE=/opt/config-file.yaml
COPY routes.txt .
ENV RMR_SEED_RT=/opt/routes.txt

ENTRYPOINT ["env","LD_LIBRARY_PATH=/usr/local/lib","./kpimon"]