require 'ronin/leverage/io'

class FakeIO < Ronin::Leverage::IO

  def initialize
    @index = 0
    @blocks = ["one\n", "two\nthree\n", "four\n"]

    super
  end

  protected

  def io_open
    3
  end

  def io_read
    block = @blocks[@index]

    @index += 1
    return block
  end

  def io_write(data)
    @blocks[@index] = data
    @index += 1

    return data.length
  end

end
