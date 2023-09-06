FROM continuumio/miniconda3:23.3.1-0

RUN conda config \
    --add channels defaults \
    --add channels bioconda \
    --add channels conda-forge

RUN apt-get update
RUN apt-get install -y curl gnupg1 r-base #trim-galore cutadapt

RUN conda install bioconductor-msa
RUN conda install -c conda-forge r-stringr
RUN conda install -c conda-forge r-dplyr
RUN conda install -c conda-forge r-purrr
RUN conda install -c conda-forge r-readr
RUN conda install -c conda-forge r-reshape2
RUN conda install -c conda-forge r-ggplot2
RUN conda install -c conda-forge r-tidyr
RUN conda install -c bioconda bioconductor-biostrings
RUN conda install -c bioconda bioconductor-ggmsa
RUN conda install -c bioconda bioconductor-decipher

# Specific for google cloud support
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

RUN curl https://sdk.cloud.google.com | bash
ENV PATH=/root/google-cloud-sdk/bin/:${PATH}

#Setup crcmodc for gsutil:
RUN apt-get install -y gcc python3-dev python3-setuptools && pip3 uninstall -y crcmod && pip3 install --no-cache-dir -U crcmod

COPY FindKmersASVs.pl .
COPY script2_vgsc.R .
COPY script1_vgsc.R .	
#COPY seqtab_mixed.tsv .
#COPY ASVBimeras.txt .
#COPY master.sh .	
#COPY vgsc_kmers.txt .
