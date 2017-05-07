#!/bin/bash
go get -u github.com/square/certstrap
go get -u github.com/compozed/deployadactyl
go get code.cloudfoundry.org/cfdot && \
   cd $GOPATH/src/code.cloudfoundry.org/cfdot && GOOS=linux go build .
