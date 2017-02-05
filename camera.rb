require 'rmagick'
include Magick

puts "Creating folder"
folder_timestamp = Time.now.to_i
system("mkdir pictures/#{folder_timestamp}") # Creates desitnation folder for photobooth sessions

# Takes 4 pictures
i = 1
4.times do
  puts "Taking picture"
  sleep 1
  puts "3..."
  sleep 1
  puts "2..."
  sleep 1
  puts "1..."
  sleep 1
  system("raspistill -t 1 -w 1000 -h 1000 -vf -o pictures/#{folder_timestamp}/#{i}.jpg") # Takes picture in 1 second, scales to 1000x1000, flips vertically
  puts "Picture #{i} captured"
  i = i + 1
end


puts "Creating gif..."
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

animation = ImageList.new(*Dir["composite*.jpg"]) # Grabs all the new overlayed images
animation.delay = 100
animation.write("animated.gif") # Creates a gif with a 100ms delay between frames and saves it to the timestampped folder

puts "All done!"