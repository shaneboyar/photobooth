# require 'pi_piper'
# include PiPiper
class Timer

  def initialize
    @segments = {
      cross: PiPiper::Pin.new(:pin => 21, :direction => :out),
      ul: PiPiper::Pin.new(:pin => 12, :direction => :out),
      uc: PiPiper::Pin.new(:pin => 13, :direction => :out),
      ur: PiPiper::Pin.new(:pin => 19, :direction => :out),
      bl: PiPiper::Pin.new(:pin => 16, :direction => :out),
      bc: PiPiper::Pin.new(:pin => 26, :direction => :out),
      br: PiPiper::Pin.new(:pin => 20, :direction => :out)
    }
  end

  def display_three
    @segments[:uc].on
    @segments[:ur].on
    @segments[:cross].on
    @segments[:br].on
    @segments[:bc].on
  end

  def display_two
    @segments[:uc].on
    @segments[:ur].on
    @segments[:cross].on
    @segments[:bl].on
    @segments[:bc].on
  end

  def display_one
    @segments[:ur].on
    @segments[:br].on
  end

  def display_all
    @segments.each { |k,v| v.on }
  end

  def clear
    @segments.each { |k,v| v.off }
  end

  def test
    display_three
    sleep(1)
    clear
    sleep(1)
    display_two
    sleep(1)
    clear
    sleep(1)
    display_one
    sleep(1)
    clear
  end

end
