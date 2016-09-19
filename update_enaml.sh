#!/bin/bash
# updates Enaml

# ARCH can be either $ARCH or osx at the moment.

download_omg(){
  local i

  echo "Upgrading from version $omg_existing_version to $omg_ghub_version."
  echo "Downloading Enaml omg and cloud-configs..."
  cd $CCONF
  for i in \
      $(curl -s "https://api.github.com/repos/enaml-ops/omg-cli/releases/latest" \
      | jq --raw-output '.assets[] | .browser_download_url' | grep $ARCH); do
  wget -q $i -O $(basename $i)
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
  wget -q $i -O $(basename $i)
  done
}

register_cloudconfigs(){
  cd $HOME
  echo "Registering cloud configs..."
  find $CCONF -type f -print | while read i; do \
       $OMGBIN/omg register-plugin -type cloudconfig -pluginpath $i
  done
}

register_products(){
  cd $HOME
  echo "Registering products..."
  find $PROD -type f -print | while read i; do
       $OMGBIN/omg register-plugin -type product -pluginpath $i
  done
}

# Main
if [ -z "$ENAML" ]; then
  echo "Please set the \$ENAML variable. This is the directory where Enaml will be installed. This program will overwrite that directory."
  exit 1
fi

ARCH=linux
PROD=$ENAML/products
CCONF=$ENAML/cloudconfig
PLUGINS=$HOME/.plugins
OMGBIN=$HOME/bin

mkdir -p $PROD
mkdir -p $CCONF
mkdir -p $OMGBIN

cd $HOME

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
