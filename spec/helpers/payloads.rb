require 'ronin/payloads/payload'

require 'helpers/output'

module Helpers
  PAYLOADS_DIR = File.expand_path(File.join(File.dirname(__FILE__),'cache','payloads'))

  def load_payload(name,base=Ronin::Payloads::Payload)
    base.load_from(File.join(PAYLOADS_DIR,"#{name}.rb"))
  end
end
