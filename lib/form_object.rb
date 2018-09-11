class FormObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def initialize(attrs = {})
    attrs.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.named(name)
    @named ||= ActiveModel::Name.new(self, nil, name)
  end

  def self.model_name
    @named || super
  end

  def persisted?
    false
  end
end
