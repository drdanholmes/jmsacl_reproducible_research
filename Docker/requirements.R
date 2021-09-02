#!/usr/bin/env Rscript

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


# args = commandArgs(trailingOnly = TRUE)

# packages_path <- as.character(args[1])
# print(args[1])

# fl <- list.files(
# 	path = file.path(packages_path),
# 	full.names = FALSE,
# 	pattern = "tar.gz"
# )

# s <- base::strsplit(fl, split = '_', fixed = TRUE)
# ss <- sapply(s, '[[', 1)
# print(ss)
# print("START: Installing above packages from local repo...")
# system.time(install.packages(c(print(
# 	as.character(ss, collapse = "\",\"")
# )),
# contriburl = paste0("file://", packages_path)))
# print("END: Installing above packages from local repo...")

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
