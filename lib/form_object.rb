class FormObject
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def initialize(attrs = {})
    attrs = Hash(attrs)
    attrs.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.named(name)
    @model_name ||= ActiveModel::Name.new(self, nil, name)
  end

  def self.model_name
    @model_name || super
  end

  def persisted?
    false
  end
end
