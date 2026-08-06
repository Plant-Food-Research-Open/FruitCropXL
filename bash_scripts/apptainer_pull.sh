#!/usr/bin/env bash

# Update the Apptainer repository URL and tag to the new values
# GITHUB_APPTAINER_REPO=oras://containerhub.pfr.co.nz/powerplant/groimp-openjdk11-src-2.0.1
GITHUB_APPTAINER_REPO=oras://ghcr.io/junqi108/groimp
GITHUB_APPTAINER_TAG=latest
GROIMP_APPTAINER_IMAGE=groimp  # Name of the image file

###################################################################
# Main
###################################################################

# Pull the Apptainer image
apptainer pull "$GITHUB_APPTAINER_REPO:$GITHUB_APPTAINER_TAG"

# Construct the downloaded image name
DOWNLOADED_IMAGE_NAME="${GROIMP_APPTAINER_IMAGE}_${GITHUB_APPTAINER_TAG}.sif"

# Move the image to the 'images' directory and rename it to 'groimp.sif'
mv "$DOWNLOADED_IMAGE_NAME" images/groimp.sif
