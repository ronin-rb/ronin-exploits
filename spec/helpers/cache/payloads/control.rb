ronin_payload do
  cache do
    self.name = 'control'
    self.version = '0.2'
  end

  build do
  end

  deploy do
  end

  control_file_read do |path|
    'data'
  end

  control_file_write do |path|
  end
end
