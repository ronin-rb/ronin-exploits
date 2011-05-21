require 'ronin/encoders/encoder'

module Helpers
  ENCODERS_DIR = File.expand_path(File.join(File.dirname(__FILE__),'scripts','encoders'))

  def load_encoder(name,base=Ronin::Encoders::Encoder)
    base.load_object(File.join(ENCODERS_DIR,"#{name}.rb"))
  end
end
