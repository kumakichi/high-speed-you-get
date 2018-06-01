#!/bin/bash

REPO_PATH="https://github.com/soimort/you-get/"
TARGET_FILE="you-get/src/you_get/common.py"
NEW_LINE="_NEW_LINE_"

function patch() {
  IFS=''
  content=""
  while read line
  do
    content+=${line}"${NEW_LINE}"
  done<template
    
  sed -i ':a;N;$!ba;s/\n/'${NEW_LINE}'/g' ${TARGET_FILE}
  sed -i "s@\(.*def url_save(\)\([^)]*):\)\(.*\)@\1\2${NEW_LINE}${content}${NEW_LINE}\3@g" ${TARGET_FILE}
  grep 'def url_save_chunked(' "${TARGET_FILE}" >/dev/null 2>&1
  if [ $? -eq 0 ]
  then
    sed -i "s@\(.*def url_save_chunked(\)\([^)]*):\)\(.*\)@\1\2${NEW_LINE}${content}${NEW_LINE}\3@g" ${TARGET_FILE}
  fi
  sed -i "s/${NEW_LINE}/\n/g" ${TARGET_FILE}
}

function check_directory() {
  if [ ! -f ${TARGET_FILE} ]
  then
    echo "Use this script under you-get root directory"
    exit
  fi
}

if [ $# -gt 0 ]
then
  c=$1
else
  if [ ! -d "you-get" ]
  then
    c="init"
  else
    echo "Directory already exist, if you wanna update you-get, type: $0 update"
    exit
  fi
fi

case $c in
  "init")
    if [ -d "you-get" ]
    then
      echo "Directory already exist, if you wanna update you-get, type: $0 update"
      exit
    fi
    git clone "${REPO_PATH}"
    patch
  ;;
  "update")
    check_directory
    cd you-get
    git checkout .
    git pull
    cd -
    patch
  ;;
  -h|--help)
    echo "Usage: $0 [init/update]. By default, do the patch work."
  ;;
  *)
    echo "not supported: '$*'"
  ;;
esac
