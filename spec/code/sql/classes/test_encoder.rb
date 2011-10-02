require 'ronin/code/sql/encoder'

class TestEncoder

  include Ronin::Code::SQL::Encoder

  def test_keyword(keyword)
    encode_keyword(keyword)
  end

  def test_null
    encode_null
  end

  def test_boolean(bool)
    encode_boolean(bool)
  end

  def test_integer(int)
    encode_integer(int)
  end

  def test_float(float)
    encode_float(float)
  end

  def test_string(string)
    encode_string(string)
  end

  def test_list(*array)
    encode_list(*array)
  end

  def test_hash(hash)
    encode_hash(hash)
  end

  def test(*elements)
    encode(*elements)
  end

  def test_join(*elements)
    encode_elements(*elements)
  end

end
