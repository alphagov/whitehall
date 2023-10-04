FactoryBot.define do
  factory :image do
    alt_text { "An accessible description of the image" }
    image_data
  end

  factory :image_with_asset, parent: :image do
    after(:build) do |image|
      image.image_data = build(:image_data_with_assets)
    end
  end
end
