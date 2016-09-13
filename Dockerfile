FROM ubuntu:xenial
MAINTAINER Ramiro Salas <rsalas@pivotal.io>

ENV HOME /home/ops
ENV ENAML /opt/enaml
ENV GOPATH $HOME/bin
ENV GOROOT /usr/local/go
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/bin:$GOROOT/bin:$GOPATH/bin

RUN mkdir -p $ENAML/products && mkdir -p $ENAML/cloudconfig
ADD update_enaml.sh /usr/local/bin

RUN mkdir $HOME
RUN useradd -M -d $HOME ops
VOLUME $HOME
RUN chown -R ops: $HOME $ENAML
WORKDIR $HOME
RUN mkdir -p $HOME/bin
RUN cp -n /etc/skel/.[a-z]* .

RUN cat /etc/apt/sources.list | sed 's/archive/us.archive/g' > /tmp/s && mv /tmp/s /etc/apt/sources.list
RUN apt-get update && apt-get -y --no-install-recommends install wget -q curl
RUN apt-get -y --no-install-recommends install ruby libroot-bindings-ruby-dev \
           build-essential git curl software-properties-common dnsutils \
           traceroute jq vim wget -q unzip sudo iperf screen tmux byobu

RUN wget -q -O - "https://storage.googleapis.com/golang/go1.7.1.linux-amd64.tar.gz" \
    | tar -C /usr/local -zx

RUN go get github.com/concourse/fly && mv $GOPATH/bin/fly /usr/local/bin

RUN curl -L \
    "https://cli.run.pivotal.io/stable?release=linux64-binary&source=github" \
    | tar -C /usr/local/bin -zx

RUN wget $(wget -q -O- https://bosh.io/docs/install-bosh-init.html | grep "bosh-init for Linux (amd64)" | awk -F "\'" '{print$2}') -O /usr/local/bin/bosh-init
RUN chmod 755 /usr/local/bin/bosh-init

RUN wget $(wget -O- -q https://www.vaultproject.io/downloads.html | grep linux_amd | awk -F "\"" '{print$2}') -O vault.zip && unzip vault.zip && cp vault /usr/local/bin/vault
RUN chmod 755 /usr/local/bin/vault

RUN cd /usr/local/bin/ && curl -o terraform.zip \
    "https://releases.hashicorp.com/terraform/0.7.3/terraform_0.7.3_linux_amd64.zip" \
    && unzip terraform.zip && rm -f terraform.zip

RUN gem install bosh_cli --no-ri --no-rdoc
RUN gem install cf-uaac --no-rdoc --no-ri

RUN cd /tmp && git clone https://github.com/square/certstrap && \
    cd certstrap/ && ./build && mv bin/certstrap /usr/local/bin/ && cd /tmp && \
    rm -rf certstrap

RUN cd /usr/local/bin && wget -q -O spiff \
    "$(curl -s https://api.github.com/repos/cloudfoundry-incubator/spiff/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x spiff

RUN cd /usr/local/bin && wget -q -O spruce \
    "$(curl -s https://api.github.com/repos/geofffranks/spruce/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x spruce

RUN cd /usr/local/bin && wget -q -O safe \
    "$(curl -s https://api.github.com/repos/starkandwayne/safe/releases/latest \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux | grep -v zip)" && chmod +x safe

RUN curl "https://raw.githubusercontent.com/starkandwayne/genesis/master/bin/genesis" > /usr/bin/genesis \
    && chmod 0755 /usr/bin/genesis

RUN baseURL=$(wget -q -O- https://github.com/vmware/photon-controller/releases/ | grep -m 1 photon-linux | perl -ne 'print map("$_\n", m/href=\".*?\"/g)' |  tr -d '"' | awk -F "href=" '{print$2}') && wget https://github.com$baseURL -O /usr/local/bin/photon
RUN chmod 755 /usr/local/bin/photon

RUN apt-get clean && apt-get -y autoremove
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN echo "ops      ALL=NOPASSWD: ALL" >> /etc/sudoers

USER ops
