### This is built to run on a Raspbery Pi using the integrated camera module

apt-get update && apt-get upgrade

apt-get install rubygems bundler libssl-dev imagemagick libmagickwand-dev

bundle install

ssh into Raspi (using https://github.com/thoqbk/pi-oi to find IP)

stty -F /dev/ttyUSB0 -hupcl

cd path/to/photobooth

sudo ruby camera.rb
