
index.html: rnotebook.Rmd _drake.R
	Rscript -e "library(rmarkdown); rmarkdown::render('$<', output_file = '$@')"
