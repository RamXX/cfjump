#!/bin/bash
echo Installing CF plugins
sudo cf install-plugin -f $GOBIN/autopilot > /dev/null
sudo cf install-plugin -f $GOBIN/cf-mysql-plugin > /dev/null
sudo cf install-plugin -f $GOBIN/cf-service-connect > /dev/null
sudo cf install-plugin -f -r CF-Community top > /dev/null
sudo chown -R ops:ops $HOME > /dev/null
sudo cf plugins
