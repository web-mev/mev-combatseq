FROM r-base:3.6.1

RUN apt-get update && \
  apt-get install -y libxml2-dev \
  libcurl4-openssl-dev \
  libssl-dev

# Install all software under /opt/software
RUN mkdir -p /opt/software
ADD combatseq.R /opt/software/

# Install directly from github maintained by the developer (instead of Bioc repo)
RUN R -e 'install.packages(c("devtools"))'
RUN R -e 'devtools::install_github("zhangyuqing/sva-devel")'

ENTRYPOINT ["/bin/bash"]
