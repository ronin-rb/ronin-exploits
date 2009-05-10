ronin_payload do
  parameter :var,
            :value => 'usual',
            :description => 'Parameter set by an exploit'

  cache do
    self.name = 'example'
    self.version = '0.2'

    arch :i686
    os :name => 'Linux'

    author :name => 'Anonymous', :email => 'anonymous@example.com'
  end

  def build
    @payload = "data/#{@var}"
  end
end
