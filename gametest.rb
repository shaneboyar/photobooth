require 'gosu'

class GameWindow < Gosu::Window
  def initialize
    super 800, 480, fullscreen: false, update_interval: 2000
    self.caption = "Photo Booth"
    @count = 0
    @background_image = Gosu::Image.new("finn.gif", :tileable => true)
  end

  def update
    close if @count == 5
    @background_image = Gosu::Image.new("intro.png") if @count == 2
    puts @count
    @count = @count + 1
  end

  def draw
    @background_image.draw(0, 0, 0)
  end

  def button_down(id)
    if id != Gosu::KbEscape
      close
    end
  end
end

GameWindow.new.show
