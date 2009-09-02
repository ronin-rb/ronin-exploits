ronin_payload do
  parameter :custom,
            :default => 'func',
            :description => 'Custom value to use in building the payload'

  cache do
    self.name = 'simple'

    control :code_exec

    author :name => 'Anonymous', :email => 'anonymous@example.com'
  end

  def build
    @payload = "code.#{@custom}"
  end

  def some_control
    'control data'
  end
end
