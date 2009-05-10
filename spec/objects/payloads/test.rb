ronin_payload do
  cache do
    self.name = 'test'
  end

  def build
    @payload = 'code'
  end
end
