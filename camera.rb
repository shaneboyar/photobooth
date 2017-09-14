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
    i = i + 1
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

  def process_gif(delay = 50, output_file_name = "animated.gif")
    puts "Processing Gif"
    gif_frames = []
    gif_frames << MiniMagick::Image.open("./pictures/#{folder_timestamp}/composite1.jpg")
    gif_frames << MiniMagick::Image.open("./pictures/#{folder_timestamp}/composite2.jpg")
    gif_frames << MiniMagick::Image.open("./pictures/#{folder_timestamp}/composite3.jpg")
    system("convert -delay 50 ./pictures/2/composite* -loop 0 ./pictures/#{folder_timestamp}/animated.gif")
  end

  process_gif

  puts "Uploading Gif"

  RestClient.post('http://www.shaneandstephanie.com/photobooth', file: File.new('animated.gif'))
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

  Dir.chdir("../../") # Moves back into root folder

  puts "All done!\n"
  ser.write("k")
  puts "Ready!"
end

PiPiper.watch :pin => 21, :pull => :up do # Watches for button press into pin 25
  run
end
PiPiper.wait
