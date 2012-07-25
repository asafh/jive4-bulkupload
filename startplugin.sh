#!/bin/bash
echo "Bulding Plugin"
mvn install
echo "Building plugin finished"
#curDir=$PWD
#echo $curDir
cd ../web/
echo "Restarting web without redeploy"
mvn -Dcargo.wait=true -Djive.ws.disabled=true -P int cargo:start
