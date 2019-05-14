#!/bin/bash

r=`sensors|grep '^[a-zA-Z0-9].[[:print:]]*:.\s*\S*[0-9].\s*[A-Z].' -o|sed 's/:\ */:/g'|sed 's/:/":"/g'|sed 's/^/"/g' |sed 's/$/",/g'|sed 's/\ C\ /C/g'|sed 's/\ V\ /V/g'|sed 's/\ RP/RPM/g'|sed 's/\ //g'|awk 'BEGIN{ORS=""}{print $0}'|sed 's/,$//g'`
r="{"$r"}"
echo $r;
#>/cgi/sensor.json
