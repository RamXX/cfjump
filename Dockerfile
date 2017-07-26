FROM ubuntu:16.04
MAINTAINER Ramiro Salas <rsalas@pivotal.io>

ENV HOME /home/ops
ENV ENAML /opt/enaml
ENV OMG_PLUGIN_DIR $ENAML/plugins
ENV OMGBIN $ENAML/bin
ENV CFPLUGINS /opt/cf-plugins
ENV GOPATH /opt/go
ENV GOBIN /opt/go/bin
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/bin:/usr/local/go/bin:$GOBIN:$OMGBIN

ADD update_enaml.sh /usr/local/bin

RUN mkdir -p $HOME
RUN mkdir -p $ENAML
RUN mkdir -p $GOBIN
RUN mkdir -p $CFPLUGINS
RUN mkdir -p $OMG_PLUGIN_DIR
RUN groupadd -g 9024 ops
RUN useradd --shell /bin/bash -u 9024 -g 9024 -o -c "" -M -d $HOME ops
VOLUME $HOME
RUN chown -R ops:ops $HOME
WORKDIR $HOME
RUN mkdir -p $HOME/bin
RUN cp -n /etc/skel/.[a-z]* .

RUN cat /etc/apt/sources.list | sed 's/archive/us.archive/g' > /tmp/s && mv /tmp/s /etc/apt/sources.list

RUN apt-get update && apt-get -y --no-install-recommends install wget curl
RUN apt-get -y --no-install-recommends install ruby libroot-bindings-ruby-dev \
           build-essential git ssh zip software-properties-common dnsutils \
           iputils-ping traceroute jq vim wget unzip sudo iperf screen tmux \
           file openstack tcpdump nmap less s3cmd s3curl direnv \
           netcat npm nodejs-legacy python3-pip python3-setuptools \
           apt-utils libdap-bin mysql-client mongodb-clients postgresql-client-9.5 \
           redis-tools libpython2.7-dev libxml2-dev libxslt-dev

RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-xenial main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && sudo apt-get -y --no-install-recommends install google-cloud-sdk

RUN curl -O https://bootstrap.pypa.io/get-pip.py && python2.7 ./get-pip.py && rm -f python2.7 ./get-pip.py

RUN pip3 install --upgrade pip

RUN pip3 install awscli

RUN npm install -g azure-cli

RUN curl -L \
    "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" \
    | tar -C /usr/local/bin -zx

RUN wget $(wget -O- -q https://www.vaultproject.io/downloads.html | grep linux_amd | awk -F "\"" '{print$2}') -O vault.zip && unzip vault.zip && cp vault /usr/local/bin/vault
RUN chmod 755 /usr/local/bin/vault

RUN cd /usr/local/bin/ && curl -o terraform.zip \
    "https://releases.hashicorp.com/terraform/0.9.11/terraform_0.9.11_linux_amd64.zip" \
    && unzip terraform.zip && rm -f terraform.zip

RUN gem install cf-uaac --no-rdoc --no-ri

RUN cd /usr/local/bin && wget -q -O om \
    "$(curl -s https://api.github.com/repos/pivotal-cf/om/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x om 

RUN cd /usr/local/bin && wget -q -O fly \
    "$(curl -s https://api.github.com/repos/concourse/fly/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x fly

RUN cd /usr/local/bin && wget -q -O magnet \
    "$(curl -s https://api.github.com/repos/pivotalservices/magnet/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x magnet

RUN cd /usr/local/bin && wget -q -O bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.28-linux-amd64 && chmod 0755 bosh && ln -s bosh bosh2

RUN cd /usr/local/bin && wget -q -O omg-transform \
    "$(curl -s https://api.github.com/repos/enaml-ops/omg-transform/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep omg-transform-linux)" && chmod +x omg-transform

RUN cd /usr/local/bin && wget -q -O pivnet \
    "$(curl -s https://api.github.com/repos/pivotal-cf/pivnet-cli/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x pivnet

RUN cd /usr/local/bin && wget -q -O bbl \
    "$(curl -s https://api.github.com/repos/cloudfoundry/bosh-bootloader/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x bbl 

RUN cd /usr/local/bin && wget -q -O cfops \
    "$(curl -s https://api.github.com/repos/pivotalservices/cfops/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url')" && chmod +x cfops

RUN cd /usr/local/bin && wget -q -O spiff https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.8/spiff_linux_amd64.zip \
    && chmod +x spiff

RUN cd /usr/local/bin && wget -q -O spruce \
    "$(curl -s https://api.github.com/repos/geofffranks/spruce/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x spruce

RUN cd /usr/local/bin && wget -q -O safe \
    "$(curl -s https://api.github.com/repos/starkandwayne/safe/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x safe

RUN cd /usr/local/bin && wget -q -O asg-creator \
    "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/asg-creator/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x asg-creator

RUN cd /usr/local/bin && wget -q -O cf-mgmt \
    "$(curl -s https://api.github.com/repos/pivotalservices/cf-mgmt/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x cf-mgmt

RUN curl "https://raw.githubusercontent.com/starkandwayne/genesis/master/bin/genesis" > /usr/bin/genesis \
    && chmod 0755 /usr/bin/genesis

# Thanks to Merlin Glynn for the Photon part!
RUN baseURL=$(wget -q -O- https://github.com/vmware/photon-controller/releases/ | grep -m 1 photon-linux | perl -ne 'print map("$_\n", m/href=\".*?\"/g)' |  tr -d '"' | awk -F "href=" '{print$2}') && wget https://github.com$baseURL -O /usr/local/bin/photon
RUN chmod 755 /usr/local/bin/photon

RUN cd /usr/local/bin && wget -q -O cliaas \
    "$(curl -s https://api.github.com/repos/pivotal-cf/cliaas/releases/latest|jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x cliaas

RUN cd /usr/local/bin && wget -q -O - https://github.com/cloudfoundry-incubator/credhub-cli/releases/download/1.2.0/credhub-linux-1.2.0.tgz | tar xzf - > credhub && chmod 0755 credhub

RUN cd /usr/local/bin && \
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod 0755 kubectl

RUN cd $CFPLUGINS && wget -q -O autopilot \
    "$(curl -s https://api.github.com/repos/xchapter7x/autopilot/releases/latest|jq --raw-output '.assets[] | .browser_download_url' | grep linux|grep -v zip)" && chmod +x autopilot

RUN cd $CFPLUGINS && wget -q -O cf-mysql-plugin https://github.com/andreasf/cf-mysql-plugin/releases/download/v1.4.0/cf-mysql-plugin-linux-amd64 && \
    chmod 0755 ./cf-mysql-plugin 
RUN cd $CFPLUGINS && wget -q -O cf-service-connect https://github.com/18F/cf-service-connect/releases/download/1.1.0/cf-service-connect.linux64 && \
    chmod 0755 ./cf-service-connect

RUN cd /usr/local/bin && wget -q -O goblob \
    "$(curl -s https://api.github.com/repos/pivotal-cf/goblob/releases/latest|jq --raw-output '.assets[] | .browser_download_url' | grep linux)" && chmod +x goblob

RUN git clone https://github.com/cf-platform-eng/nsx-edge-gen.git && \
    pip2 install -r nsx-edge-gen/requirements.txt && pip2 install tabulate pynsxv && mv nsx-edge-gen /opt

RUN pip2 install tile-generator

RUN mkdir -p .bucc && git clone https://github.com/starkandwayne/bucc.git && \
    ln -s $HOME/.bucc/bucc/bin/bucc /usr/local/bin/bucc

ADD firstrun.sh /usr/local/bin
ADD add_go.sh /usr/local/bin
ADD add_extras.sh /usr/local/bin
RUN chown -R ops:ops /opt $HOME $GOBIN $GOPATH
RUN apt-get -y autoremove && apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

RUN echo "ops ALL=NOPASSWD: ALL" >> /etc/sudoers

USER ops

CMD ["/bin/bash"]
