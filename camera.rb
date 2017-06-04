require 'rest-client'
require 'rmagick'
include Magick
require 'pi_piper'
include PiPiper
require './timer'

white_led = PiPiper::Pin.new(:pin => 18, :direction => :out)
timer = Timer.new

puts "Ready!"

PiPiper.watch :pin => 25, :pull => :up do # Watches for button press into pin 25
  footer = ImageList.new('footer.jpg')
  puts "Creating folder"
  folder_timestamp = Time.now.to_i
  system("mkdir pictures/#{folder_timestamp}") # Creates desitnation folder for photobooth sessions

  # Takes 4 pictures
  i = 1
  4.times do
    puts "Taking picture"
    sleep 1
    timer.display_three
    puts "3..."
    sleep 1
    timer.clear
    sleep 1
    timer.display_two
    puts "2..."
    sleep 1
    timer.clear
    sleep 1
    timer.display_one
    puts "1..."
    sleep 1
    timer.clear
    sleep 1
    white_led.on
    system("raspistill -t 1 -w 1000 -h 1000 -o pictures/#{folder_timestamp}/#{i}.jpg -cfx 128:128") # Takes picture in 1 second, scales to 1000x1000, flips vertically, sets to grayscsale
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

  puts "Overlaying Images"
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

  puts "Processing Strip"
  i = 0
  il.each do |image|
    result = image.border(0, 5, "white")
    result.write("border#{i}.jpg")
    i = i + 1
  end
  il = ImageList.new(*Dir["border*.jpg"])
  il += footer
  result = il.append(true)
  result.write("strip.jpg")

  def process_gif(delay = 50, output_file_name = "animated.gif")
    puts "Processing Gif"
    animation = ImageList.new(*Dir["composite*.jpg"]) # Grabs all the new overlayed images
    animation.delay = delay
    animation.write("animated.gif")
  end

  process_gif

  puts "Uploading Gif"

  RestClient.post('http://www.shaneandstephanie.com/photobooth', file: File.new('animated.gif'))
  puts "\nCleaning Up"
  File.delete('composite0.jpg')
  File.delete('composite1.jpg')
  File.delete('composite2.jpg')
  File.delete('composite3.jpg')
  File.delete('border0.jpg')
  File.delete('border1.jpg')
  File.delete('border2.jpg')
  File.delete('border3.jpg')
  File.delete('animated.gif')
  #File.delete('strip.jpg') This is just being commented for now while I work on strip design.

  Dir.chdir("../../") # Moves back into root folder

  puts "All done!"
  puts "Ready!"
end
PiPiper.wait
