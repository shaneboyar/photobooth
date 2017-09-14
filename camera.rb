require 'rest-client'
require 'mini_magick'
include MiniMagick
require 'pi_piper'
include PiPiper
require 'serialport'


puts "Ready!"

def next_arduino_step(serialport)
  serialport.write("k")
end


def run
  ser = SerialPort.new('/dev/ttyUSB0', 9600)
  next_arduino_step(ser) # All on Red
  puts "Creating folder"
  folder_timestamp = Time.now.to_i
  system("mkdir pictures/#{folder_timestamp}") # Creates desitnation folder for photobooth sessions

  # Takes 3 pictures
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
    sleep 1
    i += 1
  end

  puts "Overlaying Images"
  overlay = MiniMagick::Image.open("overlay.png") # Grabs transparent overlay image from project folder
  il = []
  # Grabs all the pictures taken by the photobooth
  il << MiniMagick::Image.open("./pictures/#{folder_timestamp}/1.jpg")
  il << MiniMagick::Image.open("./pictures/#{folder_timestamp}/2.jpg")
  il << MiniMagick::Image.open("./pictures/#{folder_timestamp}/3.jpg")
  # Loops through images an places overlay on them
  i = 1
  il.each do |image|
    # Overlays center is on center of picture
    result = image.composite(overlay) do |c|
      c.compose "Over"
      c.geometry "+0+0"
    end
    result.write("./pictures/#{folder_timestamp}/composite#{i}.jpg")
    i += 1
  end

  puts "Processing Strip"
  footer = MiniMagick::Image.open('footer.jpg')
  MiniMagick::Tool::Montage.new do |montage|
    il.each do |image|
      montage << image.path
    end
    montage << footer.path
    montage << "-geometry"
    montage << "+5+5"
    montage << "-tile"
    montage << "1x4"
    montage << "./pictures/#{folder_timestamp}/strip1.jpg"
  end
  FileUtils.cp("./pictures/#{folder_timestamp}/strip1.jpg", "./pictures/#{folder_timestamp}/strip2.jpg")
  MiniMagick::Tool::Montage.new do |montage|
    montage << MiniMagick::Image.open("./pictures/#{folder_timestamp}/strip1.jpg").path
    montage << MiniMagick::Image.open("./pictures/#{folder_timestamp}/strip2.jpg").path
    montage << "-geometry"
    montage << "+5+5"
    montage << "./pictures/#{folder_timestamp}/print_strip.jpg"
  end
  #  system("lp print_strip.jpg")

  puts "Processing Gif"
  system("convert -delay 50 ./pictures/#{folder_timestamp}/composite* -loop 0 ./pictures/#{folder_timestamp}/animated.gif")


  puts "Uploading Gif"

  RestClient.post('http://www.shaneandstephanie.com/photobooth', file: File.new("./pictures/#{folder_timestamp}/animated.gif"))

  puts "Cleaning Up"
  File.delete('composite0.jpg')
  File.delete('composite1.jpg')
  File.delete('composite2.jpg')
  File.delete('border0.jpg')
  File.delete('border1.jpg')
  File.delete('border2.jpg')
  File.delete('animated.gif')
  File.delete('strip1.jpg')
  File.delete('strip2.jpg')

  puts "All done!\n"
  ser.write("k")
  puts "Ready!"
end

PiPiper.watch :pin => 21, :pull => :up do # Watches for button press into pin 25
  run
end
PiPiper.wait
