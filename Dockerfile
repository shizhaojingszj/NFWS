FROM broadinstitute/genomes-in-the-cloud:2.2.3-1469027018
MAINTAINER Martin Porsch <martin.porsch@informatik.uni-halle.de>

# install system tools
RUN apt-get update -qq
RUN apt-get upgrade -qqy
RUN apt-get install -qqy git pigz

# cleanup
RUN apt-get autoremove -qqy python3 r-base r-base-dev
RUN apt-get clean

# install conda, python, snakemake, rpy2 and R
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda
ENV PATH /opt/conda/bin:$PATH
RUN conda install -c r -c bioconda python=3.5 sqlite psutil r snakemake rpy2 gffutils r-ggplot2 r-data.table

# pulling further install scripts and running them
RUN apt-get install make
RUN git clone https://github.com/GrosseLab/InstallProcedures.git
WORKDIR InstallProcedures
RUN ./bwa_0.7.15.sh
RUN ./bedtools_2.22.1.sh
RUN ./bedtools_2.25.sh
RUN ./samtools_1.3.1.sh
RUN ./fastqc_0.11.3.sh
RUN ./subread_1.5.0-p3.sh
RUN ./picard_2.5.0.sh
RUN ./trimmomatic_0.36.sh
RUN cp picard /usr/local/bin/
RUN mkdir /usr/local/bin/GenomeAnalysisTK-3.6 && mv /usr/gitc/GATK36.jar /usr/local/bin/GenomeAnalysisTK-3.6/GenomeAnalysisTK.jar && cp gatk /usr/local/bin/

# pulling core-facility rules
RUN mkdir /data 
WORKDIR /data
RUN git clone --branch develop https://github.com/GrosseLab/DefaultPipelines.git

# cleanup
#RUN apt-get autoremove -qqy python3 r-base r-base-dev
RUN rm -rf /usr/gitc

# startup
VOLUME ["/data/in"]
WORKDIR /data/in
ENTRYPOINT ["snakemake", "-j", "-k", "-p"]
