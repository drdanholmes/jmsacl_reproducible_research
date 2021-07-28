# Table of contents
* [Intro](#Introduction)
* [Docker Container](#Docker-Container)
    * [Dockerfile](#Dockerfile)
    * [Build the image]()
    * [Run the image]()
* [Managing R dependencies](#Managing-dependencies)
    * [download dependencies](#download-dependencies)
    * [install-packages](#install-packages)
    * [include and install packages in the container](#include-and-install-packages-in-the-container)

# Introduction
This repository demos a reproducible manuscript preparation for JMASCL using the R programming language and the rmarkdown and knitr packages to generate all calculated/rendered aspects of a manuscript including headers, sections, figures, tables, captions, inline numerical results (including p-values and confidence intervals), references, and reference formatting. The Docker container that is built in this repo can be found on Dockerhub at this [link](https://hub.docker.com/r/drdanholmes/jmsacl_reproducible_research). You may pull this image and run the container or you may re-build the image on your computer using the Dockerfile explained below. 

# Docker Container
Containers help us to decouple the application (in this case the manuscript) from the infrastracture. This in turn increases the reprodicibility of your work and allows others to replicate and expand your work without having to try to match your exact infrastructure. To learn more about docker and containers see [Dcoker Documentations](https://docs.docker.com/). 

## Dockerfile
The Dockerfile used in this repo, shown below, is optimized for this specific content and for accomodating the Elsevier format. It includes the minimum Linux and R dependencies that were required to process the manuscript's RMarkdown file. Therefore, it may or may not work for other Rmarkdown files. Depending on the libraries you would be using, you may need to include other packages and rebuild the image. 

```dockerfile
FROM rstudio/r-base:4.0-focal

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

# isntall required R packages
COPY requirements.R /requirements.R
RUN chmod +x requirements.R && Rscript requirements.R 

# Copy over the article's assets
COPY article /home
```

The requirements.R file is a R script with the following content. It is used to keel the Dockerfile cleaner and number of layers lower. 

```r
#!/usr/bin/env Rscript
print("START: Installing above packages from local repo...")
required_packages <-
	c("png",
	"pROC",
	"kableExtra",
	"dplyr",
	"tidyr",
	"stringr",
	"ggplot2",
	"cowplot",
	"rticles",
	"tinytex",
	"rmarkdown",
	"cpp11")

new_packages <-
	required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages))
	install.packages(new_packages, 
	dependencies = TRUE, 
	repos='https://cloud.r-project.org/' )
lapply(required_packages, require, character.only = TRUE)

print("Start: Installing tinytex requirements...")
# install tinytex
tinytex::install_tinytex()
# install extra tinetex packages needed for elsevier
tinytex::tlmgr_install(
	c(
		"elsarticle",
		"lineno",
		"colortbl",
		"multirow",
		"wrapfig",
		"pdflscape",
		"tabu",
		"varwidth",
		"threeparttable",
		"threeparttablex",
		"environ",
		"trimspaces",
		"ulem",
		"makecell"
	)
)
```

## Build the image
Place the `.Rmd` file plus other required assets (bibliography, figures, etc.) in a folder and name it `paper`. Move to the parent directory and place the Dockerfile and the `requirements.R` file in it. Then issue the following command. 

```bash
docker build . -t drdanholmes/jmsacl_reproducible_research:r4
```

## Run the image
To spin up the image as a container, navigate to the manuscipt's folder and issue the command below: 
```bash
docker run --rm -it -w /home -v $PWD:/home drdanholmes/jmsacl_reproducible_research:r4 Rscript -e 'rmarkdown::render("JMSACL_DS_v2.Rmd")'
``` 
Once successfully ran, the container will start and generate the `.pdf` file from the `.Rmd` file located in the article folder. Afterwards, the container is shutdown and the resources are freed. 

# Managing R dependencies
One way to elevate the reproducibility of a research work when using R is to include the source file of the loaded packages. To be able to include all the R dependencies, we can use a few functions from base R. First, list all the libraries used in the Rmarkdown document, then download and save them in a local folder. Subsequently, apply indexing for the local repo. 

## download dependencies
```R
# load tools package from R base 
library(tools) 

# list the libraries used in the Rmarkdown file
used_packages <- c(
	"png",
	"pROC",
	"kableExtra",
	"dplyr",
	"tidyr",
	"stringr",
	"ggplot2",
	"cowplot",
	"rticles",
	"tinytex",
	"rmarkdown",
	"cpp11"
)
# get the package dependencies
l <- package_dependencies(
	used_packages,
	available.packages(),
	which = c("Depends", "Imports", "LinkingTo"),
	recursive = TRUE
)
# add the initial libraries to the list
required_packages <-
	unique(c(as.character(unlist(l)), used_packages))

# download the package sources into a local folder
setwd("~/packages")
download.packages(packages,
				  destdir = "~/packages",
				  type = "source")

## Generate index and other required files (‘PACKAGES’, ‘PACKAGES.gz’ and ‘PACKAGES.rds’) for a repository of source files. 
write_PACKAGES("~/packages")
```
## install packages
To install the packages from a local repository issue the following commands. 
- note: change the path `~/packages` to your local repo location.
```R
# get the file list  
fl <- list.files(path = "/packages",
				 full.names = FALSE, pattern = "tar.gz")
s <- base::strsplit(fl,split = '_', fixed = TRUE)
ss <- sapply(s,'[[',1)

# install from local repo 
install.packages(c(print(as.character(ss, collapse="\",\""))),
				 contriburl="file:///packages")
```

## include and install packages in the container
in order to install the packages from source inside the container:  
1 - change the content of the requirements.R file as below. 

```r

args = commandArgs(trailingOnly = TRUE)

packages_path <- as.character(args[1])
print(args[1])

fl <- list.files(
	path = file.path(packages_path),
	full.names = FALSE,
	pattern = "tar.gz"
)

s <- base::strsplit(fl, split = '_', fixed = TRUE)
ss <- sapply(s, '[[', 1)
print(ss)
print("START: Installing above packages from local repo...")
system.time(install.packages(c(print(
	as.character(ss, collapse = "\",\"")
)),
contriburl = paste0("file://", packages_path)))


print("Start: Installing tinytex requirements...")
# install tinytex
tinytex::install_tinytex()
# install extra tinetex packages needed for elsevier
tinytex::tlmgr_install(
	c(
		"elsarticle",
		"lineno",
		"colortbl",
		"multirow",
		"wrapfig",
		"pdflscape",
		"tabu",
		"varwidth",
		"threeparttable",
		"threeparttablex",
		"environ",
		"trimspaces",
		"ulem",
		"makecell"
	)
)

```
2 - add following lines to the Dockerfile (note: change the /packages to the folder you have downloaded the packages into): 
```dockerfile
COPY Packages /home/packages
RUN Rscript requirements.R /packages
```