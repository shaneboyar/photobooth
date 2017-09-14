require 'pi_piper'
include PiPiper
require './runbooth.rb'


puts "Ready!"
PiPiper.watch :pin => 21, :pull => :up do # Watches for button press into pin 21
  Booth.run
end
PiPiper.wait