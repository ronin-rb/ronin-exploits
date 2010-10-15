require 'rspec'

RSpec.configure do |spec|
  spec.before(:suite) do
    # disable the EDITOR for the Exploit / Payload generators.
    ENV['EDITOR'] = nil
  end
end
