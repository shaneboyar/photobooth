require 'rest-client'
require 'mini_magick'
include MiniMagick
require 'pi_piper'
include PiPiper
require 'serialport'
# require './timer'


puts "Ready!"

def run
  ser = SerialPort.new('/dev/ttyUSB0', 9600)
  ser.write('k') # All on Red
  footer = MiniMagick::Image.open('footer.jpg')
  puts "Creating folder"
  folder_timestamp = Time.now.to_i
  system("mkdir pictures/#{folder_timestamp}") # Creates desitnation folder for photobooth sessions

  # Takes 4 pictures
  i = 1
  3.times do
    puts "Taking picture"
    sleep 1
    ser.write("k") # Begin Red Countdown
    puts "3..."
    sleep 1
    puts "2..."
    sleep 1
    puts "1..."
    sleep 1
    puts "Smile!"
    ser.write("k") # Flash for half a second
    system("raspistill -t 1 -w 591 -h 500 -o pictures/#{folder_timestamp}/#{i}.jpg -cfx 128:128 -ISO 800 -t 500") # Takes picture in 1 second, scales to 1000x1000, flips vertically, sets to grayscsale
    puts "Picture #{i} captured"
    ser.write("k") # All on Red / Cascade Red on last cycle
    i = i + 1
  end

  def loading(state)
    while true
      print "."
      sleep(0.5)
    end
  end
  puts "Overlaying Images"
  overlay = MiniMagick::Image.open("overlay.png")[0] # Grabs transparent overlay image from project folder
  Dir.chdir("./pictures/#{folder_timestamp}") # Moves into the folder created at the beginning
  il = []
  # Grabs all the pictures taken by the photobooth
  il << MiniMagick::Image.open("1.jpg")
  il << MiniMagick::Image.open("2.jpg")
  il << MiniMagick::Image.open("3.jpg")
  # Loops through images an places overlay on them
  i = 0
  il.each do |image|
    # Overlays center is on center of picture
    result = image.composite(overlay) do |c|
      c.compose "Over"
      c.geometry "+0+0"
    end
    result.write("composite#{i}.jpg")
    i = i + 1
  end

  puts "Processing Strip"
  # a = MiniMagick::Image.open("1.jpg")
  # MiniMagick::Tool::Montage.new do |montage|
  # montage << a.path
  # montage << "output.jpg"
  # end
  i = 0
  il.each do |image|
    result = image.border(2.5, 5, "white")
    result.write("border#{i}.jpg")
    i = i + 1
    result.destroy!
  end
  il = ImageList.new(*Dir["border*.jpg"])
  il += footer
  result = il.append(true)
  result.write("strip1.jpg")
  result.write("strip2.jpg")
  print_il = ImageList.new("strip1.jpg", "strip2.jpg")
  print_strip = print_il.append(false) 
  print_strip.write("print_strip.jpg")
  #  system("lp print_strip.jpg")

  def process_gif(delay = 50, output_file_name = "animated.gif")
    puts "Processing Gif"
    animation = ImageList.new(*Dir["composite*.jpg"]) # Grabs all the new overlayed images
    animation.delay = delay
    animation.write("animated.gif")
    animation.destroy!
  end

  process_gif

  puts "Uploading Gif"

  RestClient.post('http://www.shaneandstephanie.com/photobooth', file: File.new('animated.gif'))
  puts "Cleaning Up"
  il.destroy!
  overlay.destroy!
  footer.destroy!
  result.destroy!
  print_il.destroy!
  print_strip.destroy!
  File.delete('composite0.jpg')
  File.delete('composite1.jpg')
  File.delete('composite2.jpg')
  File.delete('border0.jpg')
  File.delete('border1.jpg')
  File.delete('border2.jpg')
  File.delete('animated.gif')
  File.delete('strip1.jpg')
  File.delete('strip2.jpg')

  Dir.chdir("../../") # Moves back into root folder

  puts "All done!\n"
  ser.write("k")
  puts "Ready!"
end

PiPiper.watch :pin => 21, :pull => :up do # Watches for button press into pin 25
  run
end
PiPiper.wait
