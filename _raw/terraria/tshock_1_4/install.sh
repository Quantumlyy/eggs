#!/bin/bash
# Vanilla tModloader Installation Script
#
# Server Files: /mnt/server
## install packages to get version and download links
apt update
apt install -y curl wget jq file unzip

GITHUB_PACKAGE=Pryaxis/TShock

if [ -z "$GITHUB_USER" ] && [ -z "$GITHUB_OAUTH_TOKEN" ] ; then
    echo -e "using anon api call"
else
    echo -e "user and oauth token set"
    alias curl='curl -u $GITHUB_USER:$GITHUB_OAUTH_TOKEN '
fi

## get release info and download links
LATEST_JSON=$(curl --silent "https://api.github.com/repos/$GITHUB_PACKAGE/releases/latest")
RELEASES=$(curl --silent "https://api.github.com/repos/$GITHUB_PACKAGE/releases")

if [ -z "$TSHOCK_VERSION" ] || [ "$TSHOCK_VERSION" == "latest" ]; then
    DOWNLOAD_LINK=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url)
else
    VERSION_CHECK=$(echo $RELEASES | jq -r --arg VERSION "$TSHOCK_VERSION" '.[] | select(.tag_name==$VERSION) | .tag_name')
    if [ "$TSHOCK_VERSION" == "$VERSION_CHECK" ]; then
        DOWNLOAD_LINK=$(echo $RELEASES | jq -r --arg VERSION "$TSHOCK_VERSION" '.[] | select(.tag_name==$VERSION) | .assets[].browser_download_url')
    else
        echo -e "defaulting to latest release"
        DOWNLOAD_LINK=$(echo $LATEST_JSON | jq .assets | jq -r .[].browser_download_url)
    fi
fi

## mkdir and cd to /mnt/server/
mkdir -p /mnt/server

cd /mnt/server

## download release
echo -e "running: wget $DOWNLOAD_LINK"
wget -O TShock.zip $DOWNLOAD_LINK

## unzip contents
echo -e "unzipping contenta"
unzip ./TShock.zip
rm -r TShock.zip

## moving files up a directory
echo -e "moving files up a directory"
RELEASE_NAME=$(basename "${DOWNLOAD_LINK##*/}" ".zip")
mv ${RELEASE_NAME}/* .
rm -rf $RELEASE_NAME

## save download version
printf "%s" "$RELEASE_NAME" > "./version"

echo -e "install complete"
