#!/bin/bash
# updates Enaml and [re-]registers the plugins

download_omg(){
  local i

  echo "Upgrading from version $omg_existing_version to $omg_ghub_version."
  echo "Downloading Enaml omg and cloud-configs..."
  cd $CCONF
  for i in \
      $(curl -s "https://api.github.com/repos/enaml-ops/omg-cli/releases/latest" \
      | jq --raw-output '.assets[] | .browser_download_url' | grep $ARCH); do
  curl -s -L -O $i > $(basename $i)
  done
  chmod +x omg-$ARCH
  mv omg-$ARCH "$OMGBIN/omg-$ARCH"
  ln -f -s "$OMGBIN/omg-$ARCH" "$OMGBIN/omg"
}

download_products(){
  local i

  echo "Upgrading from version $prod_existing_version to $prod_ghub_version."
  echo "Downloading Enaml products..."
  cd $PROD
  for i in $(curl -s "https://api.github.com/repos/enaml-ops/omg-product-bundle/releases/latest" \
      |jq --raw-output '.assets[] | .browser_download_url' | grep $ARCH); do
  curl -s -L -O $i > $(basename $i)
  done
}

register_cloudconfigs(){
  cd $OMG_PLUGIN_DIR
  echo "Registering cloud configs..."
  find $CCONF -type f -print | while read i; do \
       $OMGBIN/omg register-plugin -type cloudconfig -pluginpath $i
  done
}

register_products(){
  cd $OMG_PLUGIN_DIR
  echo "Registering products..."
  find $PROD -type f -print | while read i; do
       $OMGBIN/omg register-plugin -type product -pluginpath $i
  done
}

#######
# Main
#######

if [ -z "$ENAML" ]; then
  echo "Please set the \$ENAML variable. This is the directory where Enaml will be installed. This program will overwrite that directory."
  exit 1
fi

if [ -z "$OMG_PLUGIN_DIR" ]; then
  export OMG_PLUGIN_DIR=$HOME
  echo \$OMG_PLUGIN_DIR not specified. Set to $HOME.
else
  export OMG_PLUGIN_DIR
fi

if [ -z "$OMGBIN" ]; then
  OMGBIN=$HOME/bin
  echo \$OMGBIN not specified. Set to $HOME/bin.
fi

UNAME=$(uname -s)

if [ "$UNAME" == "Linux" ]; then
   ARCH=linux
elif [ "$UNAME" == "Darwin" ]; then
   ARCH=osx
else
   echo Unsupported architecture $UNAME
   exit 1
fi

PROD=$ENAML/products
CCONF=$ENAML/cloudconfig
PLUGINS=$OMG_PLUGIN_DIR/.plugins

mkdir -p $PROD
mkdir -p $CCONF
mkdir -p $OMGBIN

CD=$(pwd)
cd $OMG_PLUGIN_DIR

omg_ghub_version=$(curl -s "https://api.github.com/repos/enaml-ops/omg-cli/releases/latest" | jq --raw-output '.tag_name')
prod_ghub_version=$(curl -s "https://api.github.com/repos/enaml-ops/omg-product-bundle/releases/latest" | jq --raw-output '.tag_name')

if [ -f "$HOME/bin/omg-$ARCH" ]; then
   omg_existing_version=$(omg -version|awk '{print $3}'|cut -d'-' -f1)
   if [ "$omg_ghub_version" != "$omg_existing_version" ] ; then
     download_omg
   else
     echo "No new omg versions."
   fi
else
   omg_existing_version="v0.0.0"
   download_omg
fi

for x in $(omg list-products|grep version:|awk '{print $7}'|cut -d'-' -f1) ; do prod_existing_version=$x; done

if [ -z "$prod_existing_version" ] ; then
   prod_existing_version="v0.0.0"
   download_products
elif [ "$prod_existing_version" !=  "$prod_ghub_version" ] ; then
   download_products
else
   echo "No new product versions"
fi

rm -rf $PLUGINS
register_cloudconfigs
register_products
cd $CD

# EOF
