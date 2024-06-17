FactoryBot.define do
  factory :take_part_page do
    title { "A take part page title" }
    summary { "Summary text" }
    body { "Some govspeak body text" }
    image_alt_text { "Image alt text" }

    after :build do |take_part_page|
      take_part_page.image = build(:featured_image_data)
    end
  end
end
