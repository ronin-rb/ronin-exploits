require 'ronin/payloads/payload'

module Helpers
  PAYLOADS_DIR = File.expand_path(File.join(File.dirname(__FILE__),'..','objects','payloads'))

  def load_payload(name,base=Ronin::Payloads::Payload)
    base.load_from(File.join(PAYLOADS_DIR,"#{name}.rb"))
  end
end
