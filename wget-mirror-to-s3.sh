#!/bin/bash

# Variables
LOCAL_PATH = "/home/local-directory"
BA_USER = "example"
BA_PASSWORD = "example1234"
ORIGIN_DOMAIN = "origin.domain.com"
FINAL_DOMAIN = "final.domain.com"
S3_BUCKET_NAME = "final.domain.com"
S3_BUCKET_REGION = "eu-central-1"

# Backup all
tar czf $LOCAL_PATH/backups/backup.tar.gz $LOCAL_PATH/public/ &&

# '-m' ('--mirror') include '-r -l inf -N'
#   '-r' recursive
#   '-l inf' infinite recursion
#   '-N' With this option, for each file it intends to download, Wget will check whether a local file of the same name exists. If it does, and the remote file is not newer, Wget will not download it.
# '--http-user=' and '--http-password=' Specify the username user and password password on an HTTP server.
# '-e robots=off' ignore robots.txt
# '-P prefix' Set directory prefix to prefix. The directory prefix is the directory where all other files and subdirectories will be saved to, i.e. the top of the retrieval tree. The default is '.' (the current directory).
# '-nH' ('--no-host-directories') Disable generation of host-prefixed directories. By default, invoking Wget with ‘-r http://fly.srk.fer.hr/’ will create a structure of directories beginning with fly.srk.fer.hr/. This option disables such behavior.
# '-np' ('--no-parent') The simplest, and often very useful way of limiting directories is disallowing retrieval of the links that refer to the hierarchy above than the beginning directory, i.e. disallowing ascent to the parent directory/directories. 
# '-I list' option accepts a comma-separated list of directories included in the retrieval. Any other directories will simply be ignored. The directories are absolute paths.
# '--no-check-certificate' Do not check the server certificate against the available certificate authorities. Also do not require the URL host name to match the common name presented by the certificate.
# '-o file' Log all messages to logfile. The messages are normally reported to standard error.
# '-a file' Append to logfile. This is the same as ‘-o’, only it appends to logfile instead of overwriting the old log file. If logfile does not exist, a new file is created.

# Mirroring ORIGIN_DOMAIN
wget \
     -m \
     --http-user=$BA_USER \
     --http-password=$BA_PASSWORD \
     -e robots=off \
     -P $LOCAL_PATH/public \
     -nH \
     -np \
     --no-check-certificate \
     https://$ORIGIN_DOMAIN/ \
     -a $LOCAL_PATH/log/wget/$ORIGIN_DOMAIN.log &&

# Downloading /sitemap_index.xml & /post-sitemap.xml & /page-sitemap.xml
rm $LOCAL_PATH/public/sitemap\_index.xml
wget \
     --http-user=$BA_USER \
     --http-password=$BA_PASSWORD \
     -P $LOCAL_PATH/public \
     --no-check-certificate \
     https://$ORIGIN_DOMAIN/sitemap_index.xml \
     -a $LOCAL_PATH/log/wget/$ORIGIN_DOMAIN-sitemap.log &&
rm /$LOCAL_PATH/public/post-sitemap.xml
wget \
     --http-user=$BA_USER \
     --http-password=$BA_PASSWORD \
     -P $LOCAL_PATH/public \
     --no-check-certificate \
     https://$ORIGIN_DOMAIN/post-sitemap.xml \
     -a $LOCAL_PATH/log/wget/$ORIGIN_DOMAIN-sitemap.log &&
rm /$LOCAL_PATH/public/page-sitemap.xml
wget \
     --http-user=$BA_USER \
     --http-password=$BA_PASSWORD \
     -P /home/miguelmenendez.pro/public \
     https://$ORIGIN_DOMAIN/page-sitemap.xml \
     -a $LOCAL_PATH/log/wget/$ORIGIN_DOMAIN-sitemap.log &&

# ORIGIN_DOMAIN -> FINAL_DOMAIN
find $LOCAL_PATH/public/ -name \* -exec sed -i "s/$ORIGIN_DOMAIN/$FINAL_DOMAIN/g" {} \; &&

# Sync whith S3 bucket
aws s3 sync $LOCAL_PATH/public s3://$S3_BUCKET_NAME --region $S3_BUCKET_REGION --delete &&

# Acabé...
echo "Yá ta. Acabé :)"
