#! /bin/env bash

wd=$(pwd)
cd renv-16 && \
  Rscript -e 'renv::restore()' && \
  Rscript script.R 2>&1 | tee out.txt && 
  cd ${wd} \
  || echo "something went wrong"

cd renv-17 && \
  Rscript -e 'renv::restore()' && \
  Rscript script.R 2>&1 | tee out.txt && 
  cd ${wd} \
  || echo "something went wrong"


cd renv-devel && \
  Rscript -e 'renv::restore()' && \
  Rscript script.R 2>&1 | tee out.txt && 
  cd ${wd} \
  || echo "something went wrong"

