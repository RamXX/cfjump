#!/bin/bash
echo Installing CF plugins
cf install-plugin -f $GOBIN/autopilot > /dev/null
cf install-plugin -f $GOBIN/cf-mysql-plugin > /dev/null
cf install-plugin -f $GOBIN/cf-service-connect > /dev/null
cf install-plugin -f -r CF-Community top > /dev/null
cf plugins
