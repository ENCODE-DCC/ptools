# Dockerfile for ENCODE-DCC ptools pipeline
FROM ubuntu:20.04
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
