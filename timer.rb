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

  def display_nine
    @segments[:ul].on
    @segments[:uc].on
    @segments[:ur].on
    @segments[:cross].on
    @segments[:br].on
  end

  def display_eight
    @segments[:ul].on
    @segments[:uc].on
    @segments[:ur].on
    @segments[:cross].on
    @segments[:br].on
    @segments[:bc].on
    @segments[:bl].on
  end

  def display_seven
    @segments[:uc].on
    @segments[:ur].on
    @segments[:br].on
  end

  def display_six
    @segments[:uc].on
    @segments[:ul].on
    @segments[:cross].on
    @segments[:br].on
    @segments[:bc].on
    @segments[:bl].on
  end

  def display_five
    @segments[:ul].on
    @segments[:uc].on
    @segments[:cross].on
    @segments[:br].on
    @segments[:bc].on
  end

  def display_four
    @segments[:ul].on
    @segments[:cross].on
    @segments[:ur].on
    @segments[:br].on
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

  def display_zero
    @segments[:ul].on
    @segments[:uc].on
    @segments[:ur].on
    @segments[:br].on
    @segments[:bc].on
    @segments[:bl].on
  end

  def display_all
    @segments.each { |k,v| v.on }
  end

  def clear
    @segments.each { |k,v| v.off }
  end

  def test
    display_nine
    sleep(0.25)
    clear
    display_eight
    sleep(0.25)
    clear
    display_seven
    sleep(0.25)
    clear
    display_six
    sleep(0.25)
    clear
    display_five
    sleep(0.25)
    clear
    display_four
    sleep(0.25)
    clear
    display_three
    sleep(0.25)
    clear
    display_two
    sleep(0.25)
    clear
    display_one
    sleep(0.25)
    clear
    display_zero
    sleep(0.25)
    clear
  end
end
