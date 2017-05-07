#!/bin/bash
CFPLUGINS=/opt/cf-plugins
echo First run initialization. Please wait...
sudo cf install-plugin -f $CFPLUGINS/autopilot > /dev/null
sudo cf install-plugin -f $CFPLUGINS/cf-mysql-plugin > /dev/null
sudo cf install-plugin -f $CFPLUGINS/cf-service-connect > /dev/null
sudo cf install-plugin -f -r CF-Community top > /dev/null
sudo rm -rf $CFPLUGINS
sudo chown -R ops:ops $HOME > /dev/null
