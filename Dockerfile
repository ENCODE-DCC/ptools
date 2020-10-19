# Dockerfile for ENCODE-DCC ptools pipeline
FROM ubuntu@sha256:2e70e9c81838224b5311970dbf7ed16802fbfe19e7a70b3cbfa3d7522aa285b4
MAINTAINER Otto Jolanki 

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common \
    default-jre \
    wget \
    unzip \
    gcc \
    make \
    git \
    # Samtools deps
    libz-dev \
    libbz2-dev \
    libncurses5-dev \
    libcurl4-openssl-dev \
    python3-pip


RUN mkdir /software
WORKDIR /software
ENV PATH="/software:${PATH}"

# Install samtools dependencies
RUN wget https://tukaani.org/xz/xz-5.2.3.tar.gz && tar -xvf xz-5.2.3.tar.gz
RUN cd xz-5.2.3 && ./configure && make && make install && rm ../xz-5.2.3.tar.gz

# Install picard 2.23.8 
RUN wget https://github.com/broadinstitute/picard/releases/download/2.23.8/picard.jar
RUN chmod 755 picard.jar

# Install samtools 1.11
RUN git clone --branch 1.11 --single-branch https://github.com/samtools/samtools.git && \
    git clone --branch 1.11 --single-branch git://github.com/samtools/htslib.git && \
    cd samtools && make && make install && cd ../ && rm -rf samtools* htslib*

# Install python dependencies
RUN pip3 install numpy biopython

# Copy scripts into the image
RUN mkdir -p 10xscell/pbam 10xscell/pfastq
COPY /10xscell/pbam 10xscell/pbam
COPY /10xscell/pfastq 10xscell/pfastq

