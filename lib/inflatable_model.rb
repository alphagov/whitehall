class InflatableModel
  def initialize(attrs = {})
    attrs = Hash(attrs)
    attrs.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end
