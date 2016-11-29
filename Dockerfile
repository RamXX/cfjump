FROM ubuntu:xenial
MAINTAINER Ramiro Salas <rsalas@pivotal.io>

ENV HOME /home/ops
ENV ENAML /opt/enaml
ENV OMG_PLUGIN_DIR $ENAML/plugins
ENV OMGBIN $ENAML/bin
ENV GOPATH /opt/go
ENV GOBIN /opt/go/bin
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/bin:/usr/local/go/bin:$GOBIN:$OMGBIN

ADD update_enaml.sh /usr/local/bin

RUN mkdir -p $HOME
RUN mkdir -p $ENAML
RUN mkdir -p $OMG_PLUGIN_DIR
RUN useradd -M -d $HOME ops
VOLUME $HOME
RUN chown -R ops: $HOME
WORKDIR $HOME
RUN mkdir -p $HOME/bin
RUN cp -n /etc/skel/.[a-z]* .

RUN cat /etc/apt/sources.list | sed 's/archive/us.archive/g' > /tmp/s && mv /tmp/s /etc/apt/sources.list

RUN apt-get update && apt-get -y --no-install-recommends install wget curl
RUN apt-get -y --no-install-recommends install ruby libroot-bindings-ruby-dev \
           build-essential git ssh software-properties-common dnsutils \
           iputils-ping traceroute jq vim wget unzip sudo iperf screen tmux \
           file openstack tcpdump nmap less s3cmd s3curl \
           netcat npm nodejs-legacy python3-pip python3-setuptools apt-utils

RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && sudo apt-get -y --no-install-recommends install google-cloud-sdk

RUN pip3 install --upgrade pip

RUN pip3 install awscli

RUN npm install -g azure-cli

RUN wget -q -O - "https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz" \
    | tar -C /usr/local -zx

RUN curl -L \
    "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" \
    | tar -C /usr/local/bin -zx

RUN wget $(wget -q -O- https://bosh.io/docs/install-bosh-init.html | grep "bosh-init for Linux (amd64)" | awk -F "\'" '{print$2}') -O /usr/local/bin/bosh-init
RUN chmod 755 /usr/local/bin/bosh-init

RUN wget $(wget -O- -q https://www.vaultproject.io/downloads.html | grep linux_amd | awk -F "\"" '{print$2}') -O vault.zip && unzip vault.zip && cp vault /usr/local/bin/vault
RUN chmod 755 /usr/local/bin/vault

RUN cd /usr/local/bin/ && curl -o terraform.zip \
    "https://releases.hashicorp.com/terraform/0.7.4/terraform_0.7.4_linux_amd64.zip" \
    && unzip terraform.zip && rm -f terraform.zip

RUN gem install bosh_cli --no-ri --no-rdoc

RUN gem install cf-uaac --no-rdoc --no-ri

RUN go get -u github.com/cloudfoundry/bosh-cli

RUN go get -u github.com/pivotal-cf/om

RUN go get -u github.com/square/certstrap

RUN go get -u github.com/concourse/fly

RUN go get -u github.com/compozed/deployadactyl

RUN go get -u github.com/spf13/hugo

RUN cd /usr/local/bin && wget -q -O pivnet \
    "$(curl -s https://api.github.com/repos/pivotal-cf/pivnet-cli/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x pivnet

RUN cd /usr/local/bin && wget -q -O bbl \
    "$(curl -s https://api.github.com/repos/cloudfoundry/bosh-bootloader/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x bbl 

RUN cd /usr/local/bin && wget -q -O cfops \
    "$(curl -s https://api.github.com/repos/pivotalservices/cfops/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url')" && chmod +x cfops

RUN cd /usr/local/bin && wget -q -O spiff \
    "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/spiff/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x spiff

RUN cd /usr/local/bin && wget -q -O spruce \
    "$(curl -s https://api.github.com/repos/geofffranks/spruce/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x spruce

RUN go get -u github.com/starkandwayne/safe

RUN cd /usr/local/bin && wget -q -O asg-creator \
    "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/asg-creator/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x asg-creator

RUN go get github.com/pivotalservices/cf-mgmt

RUN curl "https://raw.githubusercontent.com/starkandwayne/genesis/master/bin/genesis" > /usr/bin/genesis \
    && chmod 0755 /usr/bin/genesis

RUN cd /tmp && wget -q -O opsman.tgz \
    "$(curl -s https://api.github.com/repos/datianshi/opsman/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep tgz)" && tar xzf opsman.tgz && mv out/linux/opsman-cli /usr/local/bin \
    && chmod +x /usr/local/bin/opsman-cli

# Thanks to Merlin Glynn for this part!
RUN baseURL=$(wget -q -O- https://github.com/vmware/photon-controller/releases/ | grep -m 1 photon-linux | perl -ne 'print map("$_\n", m/href=\".*?\"/g)' |  tr -d '"' | awk -F "href=" '{print$2}') && wget https://github.com$baseURL -O /usr/local/bin/photon
RUN chmod 755 /usr/local/bin/photon
RUN update_enaml.sh
RUN chown -R ops: /opt $HOME
RUN apt-get clean && apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*
RUN rm -rf $GOPATH/src $GOPATH/pkg /usr/local/go/pkg /usr/local/go/src

RUN echo "ops ALL=NOPASSWD: ALL" >> /etc/sudoers

USER ops

CMD ["/bin/bash"]
