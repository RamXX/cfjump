#!/bin/bash
# updates Enaml

# ARCH can be either $ARCH or osx at the moment.
ARCH=linux
ENAML=$HOME/enaml
PROD=$ENAML/products
CCONF=$ENAML/cloudconfig
PLUGINS=$HOME/.plugins
OMGBIN=$HOME/bin

download_omg(){
  local i

  echo "Upgrading from version $existing_version to $omg_ghub_version."
  echo "Downloading Enaml omg and cloud-configs..."
  cd $CCONF
  rm -f ./*
  for i in \
      $(curl -s "https://api.github.com/repos/enaml-ops/omg-cli/releases/latest" \
      | jq --raw-output '.assets[] | .browser_download_url' | grep $ARCH); do
          wget -q $i
  done
  chmod +x omg-$ARCH
  mv omg-$ARCH "$OMGBIN/omg-$ARCH"
  ln -f -s "$OMGBIN/omg-$ARCH" "$OMGBIN/omg"
  register_cloudconfigs
  echo "$omg_ghub_version" > "$ENAML/.omg_version"
}

download_products(){
  local i

  echo "Upgrading from version $existing_version to $prod_ghub_version."
  echo "Downloading Enaml products..."
  cd $PROD
  rm -f ./*
  for i in $(curl -s "https://api.github.com/repos/enaml-ops/omg-product-bundle/releases/latest" \
      |jq --raw-output '.assets[] | .browser_download_url' | grep $ARCH); do
          wget -q $i
  done
  register_products
  echo "$prod_ghub_version" > $ENAML/.prod_version
}

register_cloudconfigs(){
  cd $HOME
  rm -rf $PLUGINS/cloudconfig
  echo "Registering cloud configs..."
  find $CCONF -type f -print | while read i; do \
       $OMGBIN/omg register-plugin -type cloudconfig -pluginpath $i
  done
}

register_products(){
  cd $HOME
  rm -rf $PLUGINS/products
  echo "Registering products..."
  find $PROD -type f -print | while read i; do
       $OMGBIN/omg register-plugin -type product -pluginpath $i
  done
}

# Main

mkdir -p $PROD
mkdir -p $CCONF
mkdir -p $OMGBIN

omg_ghub_version=$(curl -s "https://api.github.com/repos/enaml-ops/omg-cli/releases/latest" | jq --raw-output '.tag_name')
prod_ghub_version=$(curl -s "https://api.github.com/repos/enaml-ops/omg-product-bundle/releases/latest" | jq --raw-output '.tag_name')

if [ -f "$ENAML/.omg_version" ] ; then
   existing_version=$(cat $ENAML/.omg_version)
   if [ "$omg_ghub_version" == "$existing_version" ] ; then
     echo "No new omg versions."
   else
      download_omg
   fi
else
   existing_version="Nada"
   download_omg
fi

if [ -f "$ENAML/.prod_version" ] ; then
   existing_version=$(cat $ENAML/.prod_version)
   if [ "$prod_ghub_version" == "$existing_version" ] ; then
     echo "No new product versions."
   else
     download_products
   fi
else
   existing_version="Nada"
   download_products
fi

if [ ! -d "$PLUGINS" ]; then
   register_cloudconfigs
   register_products
fi
