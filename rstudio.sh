#!/usr/bin/env bash

# We need to determine what environment we are using (dev or production) so we can load
# the container from the appropriate soure (a local dev build of the latest github build)
# Assume by default we are going to use production
CONTAINER=ghcr.io/kschaubroeck/rstudio-docker:v0.1.1

# We also want to give the user the ability to change the default port without editing the script
# just in case it's needed
PORT=8787

# Give the user's the ability to change memory allocated
MEMORY=2

# Get the porject's directory. Default name of the current directory
PROJECT_DIR=$(basename $PWD)

# Should the docker container user be given root access to the container to use `sudo` command
IS_ROOT=false

# Get the flags passed to the script
#   The project directory can be changed with the `-d` argument
#   The port can be changed with `-p`
#   The memory (in gigaybytes) allocated to RStudio can be set with `m` flag
while getopts "p:m:d:r" flag
do
    case "${flag}" in
        p) PORT=${OPTARG};;
        m) MEMORY=${OPTARG};;
        d) PROJECT_DIR=${OPTARG};;
        r) IS_ROOT=true;;
    esac
done

# Remove the parsed options from the positional params
shift $(( OPTIND - 1 ))

# Make the directories if they doesn't already exist
mkdir -p .rstudio
mkdir -p .rstudio/config
mkdir -p .rstudio/ssh
mkdir -p .rstudio/git

# Run RStudio Server
docker run \
    --mount type=bind,src=$PWD/.rstudio/config,dst=/home/rstudio/.config/rstudio \
    --mount type=bind,src=$PWD/.rstudio/ssh,dst=/home/rstudio/.ssh \
    --mount type=bind,src=$PWD/.rstudio/git,dst=/home/rstudio/.config/git \
    --mount type=bind,src=$PWD,dst=/home/rstudio/$PROJECT_DIR \
    -e PASSWORD=$1 \
    -e USERID=$(id -u) \
    -e ROOT=$IS_ROOT \
    -m "${MEMORY}g" \
    -p $PORT:8787 \
    -it \
    --rm \
    $CONTAINER
