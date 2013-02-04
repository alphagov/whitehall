FactoryGirl.define do
  factory :edition_world_location do
    edition
    world_location
  end
  factory :featured_edition_world_location, parent: :edition_world_location do
    featured true
    association :image, factory: :edition_world_location_image_data
    alt_text "An accessible description of the image"
  end
end