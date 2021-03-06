class APIFixtures
  def initialize
    @fixtures = ::JSON.parse(File.read("#{PROJECT_ROOT}/spec/fixtures.json"))
    freeze_recursively(@fixtures)
  end

  def [](name)
    @fixtures[name]
  end

  def fetch(*args)
    @fixtures.fetch(*args)
  end

  def generate_json(name)
    JSON.generate(self.fetch(name))
  end

  private

  def freeze_recursively(data)
    data.each do |k, v|
      if v.is_a?(Hash)
        freeze_recursively(v)
      end
    end
    data.freeze
  end
end