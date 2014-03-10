class Frontend::TopicMetadata < InflatableModel
  attr_accessor :slug, :name

  def to_param
    slug
  end
end
