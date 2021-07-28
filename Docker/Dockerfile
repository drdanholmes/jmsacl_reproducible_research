FROM rstudio/r-base:4.0-focal
#ARG R
ARG BUILD_DATE
#ARG PACKAGES_PATH
ENV TZ=Canada/Pacific

# install linux dependencies 
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    graphviz \
    libpng-dev \
    imagemagick \
    libmagick++-dev \
    gsfonts \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    perl \
    libicu-dev \
    pandoc 

COPY Dockerfile /Dcokerfile
# COPY Packages /home/packages
COPY article /home
# isntall required R packages
COPY requirements.R /requirements.R
RUN chmod +x requirements.R && Rscript requirements.R 

#1 docker build . -t paper-new-docker:rstudio-r4-R-cloud
