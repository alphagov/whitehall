class WorldLocationType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :sort_order, :key

  def slug
    name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.find_by_name(name)
    all.detect { |type| type.name == name }
  end

  def self.find_by_slug(slug)
    all.detect { |type| type.slug == slug }
  end

  def self.geographic
    [WorldLocation]
  end

  WorldLocation = create(id: 1, key: "world_location", name: "World location news", sort_order: 0)
  InternationalDelegation = create(id: 3, key: "international_delegation", name: "International delegation", sort_order: 2)
end
