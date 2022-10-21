FROM r-base:4.1.2

RUN apt-get update && \
  apt-get install -y libxml2-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libgit2-dev \
  libfontconfig1-dev

# Install all software under /opt/software
RUN mkdir -p /opt/software
ADD combatseq.R /opt/software/

# Install directly from github maintained by the developer (instead of Bioc repo)
RUN R -e 'install.packages(c("devtools"))'

RUN R -e 'library("devtools"); devtools::install_github("jtleek/sva-devel")'

ENTRYPOINT ["/bin/bash"]
