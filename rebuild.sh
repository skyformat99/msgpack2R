#!/usr/bin/env bash
Rscript -e "library(Rcpp); compileAttributes('.');"
Rscript -e "library(roxygen2); roxygenise('.');"


#RRO=/usr/lib64/RRO-3.2.2/R-3.2.2/bin/R
R CMD build .
R CMD INSTALL msgpack2R_0.1.tar.gz

Rscript examples/tests.r

# R CMD Rd2pdf . -o "docs/manual.pdf" --no-preview --force
# pandoc -V urlcolor=cyan -V geometry:margin=1in README.md -o docs/README.pdf

R CMD check msgpack2R_*.tar.gz --as-cran

git add .
git commit -am 'init'
git push origin master