FactoryBot.define do
  factory :generic_image, class: Image do
    alt_text { "An accessible description of the image" }

    trait(:jpg) do
      image_data
    end

    trait(:with_no_assets) do
      image_data { build(:image_data_with_no_assets) }
    end
  end

  factory :image, parent: :generic_image, traits: [:jpg]
  factory :image_with_no_assets, parent: :generic_image, traits: [:with_no_assets]
end
