# Base Image: Contains R version 4.2.3 and Rstudio Server
FROM rocker/rstudio:4.2.3@sha256:9e00f831e632b06760bc66cc0d7826ffb0bed222bea577f8b4b46d8fca79548d

# Install the packages needed for many of the libraries (including RENV)
# Afterwords we need to do some cleaning
RUN apt-get update && \
    apt-get install -y --no-install-recommends "$@" \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libxtst6 \
    libcurl4-openssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libglpk-dev \
    unixodbc-dev \
    libpcre3-dev \
    zlib1g-dev \
    libbz2-dev \
    openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    Rscript -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))" && \
    Rscript -e "remotes::install_version('renv', '0.17.2')" && \
    mkdir -p renv

# Repare to install packages by environment variables
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library

# Install packages and do some cleanup
RUN chown -R rstudio renv && \
    sudo -u rstudio R -e 'renv::restore()' && \
    rm -rf /tmp/*

# Set the working directory for the project
WORKDIR /home/rstudio
