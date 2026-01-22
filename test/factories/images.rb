FactoryBot.define do
  factory :generic_image, class: Image do
    usage { "govspeak_embed" }

    trait(:jpg) do
      image_data
    end

    trait(:with_no_assets) do
      image_data { build(:image_data_with_no_assets) }
    end

    trait(:svg) do
      image_data { build(:image_data_for_svg) }
    end
  end

  factory :image, parent: :generic_image, traits: [:jpg]
  factory :image_with_no_assets, parent: :generic_image, traits: [:with_no_assets]
end
