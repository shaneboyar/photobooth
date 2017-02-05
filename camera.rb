require 'rmagick'
include Magick
require 'pi_piper'
include PiPiper

white_led = PiPiper::Pin.new(:pin => 26, :direction => :out)


puts "Creating folder"
folder_timestamp = Time.now.to_i
system("mkdir pictures/#{folder_timestamp}") # Creates desitnation folder for photobooth sessions

# Takes 4 pictures
i = 1
4.times do
  puts "Taking picture"
  sleep 1
  white_led.on
  puts "3..."
  sleep(0.25)
  white_led.off
  sleep 1
  white_led.on
  puts "2..."
  sleep(0.25)
  white_led.off
  sleep 1
  white_led.on
  puts "1..."
  sleep(0.25)
  white_led.off
  sleep 1
  white_led.on
  system("raspistill -t 1 -w 1000 -h 1000 -vf -o pictures/#{folder_timestamp}/#{i}.jpg") # Takes picture in 1 second, scales to 1000x1000, flips vertically
  puts "Picture #{i} captured"
  white_led.off
  i = i + 1
end

def loading(state)
  while true
    print "."
    sleep(0.5)
  end
end

t1 = Thread.new{loading(true)}

print "Overlaying Images"
overlay = Magick::Image.read("overlay.png")[0] # Grabs transparent overlay image from project folder
Dir.chdir("./pictures/#{folder_timestamp}") # Moves into the folder created at the beginning
il = ImageList.new(*Dir["*.jpg"]) # Grabs all the pictures taken by the photobooth
# Loops through images an places overlay on them
i = 0
il.each do |image|
  result = image.composite(overlay, Magick::CenterGravity, Magick::OverCompositeOp) # Overlays center is on center of picture
  result.write("composite#{i}.jpg")
  i = i + 1
end

t1.exit

t1 = Thread.new{loading(true)}
print "\nProcessing Gif"
animation = ImageList.new(*Dir["composite*.jpg"]) # Grabs all the new overlayed images
animation.delay = 100
animation.write("animated.gif") # Creates a gif with a 100ms delay between frames and saves it to the timestampped folder

t1.exit

puts "\nAll done!"