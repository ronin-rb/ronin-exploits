ronin_payload do
  cache do
    self.name = 'test'

    author :name => 'Anonymous', :email => 'anonymous@example.com'
  end

  def build
    @payload = 'code'
  end
end
