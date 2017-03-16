#!/bin/bash
cf install-plugin -f $GOBIN/autopilot 
cf install-plugin -f $GOBIN/cf-mysql-plugin
cf install-plugin -f -r CF-Community top
cf plugins
