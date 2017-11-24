FactoryBot.define do
  factory :take_part_page do
    title 'A take part page title'
    summary 'Summary text'
    body 'Some govspeak body text'
    image { image_fixture_file }
    image_alt_text "Image alt text"
  end
end
