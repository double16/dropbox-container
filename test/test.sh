#!/bin/sh

# TODO: We don't have anything we can test right now, 17500 is not opened
exit 0

./wait-for-it.sh dropbox:17500

source /sh2ju.sh
juLogClean

juLog -name="opentcp" nc -zv -w 10 dropbox 17500

