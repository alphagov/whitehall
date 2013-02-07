class WorldLocationType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :sort_order, :key

  def slug
    name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.find_by_name(name)
    all.find { |type| type.name == name }
  end

  def self.find_by_slug(slug)
    all.find { |type| type.slug == slug }
  end

  Country = create( id: 1, key: "country", name: "Country", sort_order: 0 )
  OverseasTerritory = create( id: 2, key: "overseas_territory", name: "Overseas territory", sort_order: 1 )
  InternationalDelegation = create( id: 3, key: "international_delegation", name: "International delegation", sort_order: 2 )
end
