class Frontend::OrganisationMetadata < InflatableModel
  attr_accessor :slug, :name

  def to_param
    slug
  end
end
