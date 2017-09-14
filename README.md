apt-get update && apt-get upgrade

apt-get install rubygems bundler libssl-dev imagemagick libmagickwand-dev

bundle install

ssh into Raspi

stty -F /dev/ttyUSB0 -hupcl

cd path/to/photobooth

sudo ruby camera.rb
