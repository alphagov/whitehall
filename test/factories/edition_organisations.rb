FactoryGirl.define do
  factory :edition_organisation do
    organisation
  end
  factory :featured_edition_organisation, parent: :edition_organisation do
    featured true
    association :image, factory: :edition_organisation_image_data
  end
end