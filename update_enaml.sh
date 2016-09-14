#!/bin/bash
# updates Enaml
ENAML=/opt/enaml
PROD=$ENAML/products
CCONF=$ENAML/cloudconfig
PLUGINS=$HOME/.plugins
OMGBIN=$HOME/bin

mkdir -p $PROD
mkdir -p $CCONF
mkdir -p $OMGBIN

ghub_version=$(curl -s "https://api.github.com/repos/enaml-ops/omg-cli/releases/latest" | jq --raw-output '.tag_name')

if [ -f "$ENAML/.version" ] ; then
   existing_version=$(cat $ENAML/.version)
   if [ "$ghub_version" == "$existing_version" ] ; then
     echo "No new versions."
     exit 0
   else
     echo "Upgrading from version $existing_version to $ghub_version"
   fi
fi
 
echo "Downloading Enaml omg and cloud-configs"
cd $CCONF
for i in \
    $(curl -s "https://api.github.com/repos/enaml-ops/omg-cli/releases/latest" \
    | jq --raw-output '.assets[] | .browser_download_url' | grep linux); do
        wget -q $i
done
chmod +x omg-linux
mv omg-linux $OMGBIN/omg-linux
ln -f -s $OMGBIN/omg-linux $OMGBIN/omg

echo "Downloading Enaml products"
cd $PROD
for i in $(curl -s "https://api.github.com/repos/enaml-ops/omg-product-bundle/releases/latest" \
    |jq --raw-output '.assets[] | .browser_download_url' | grep linux); do
        wget -q $i
done
echo "$ghub_version" > $ENAML/.version

cd $HOME

rm -rf $PLUGINS

echo "Registering cloud configs..."
find $CCONF -type f -print | while read i; do \
    $OMGBIN/omg register-plugin -type cloudconfig -pluginpath $i
done

echo "Registering products..."
find $PROD -type f -print | while read i; do
    $OMGBIN/omg register-plugin -type product -pluginpath $i
done

omg list-cloudconfigs
omg list-products
echo "All done."
