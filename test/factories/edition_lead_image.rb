FactoryBot.define do
  factory :edition_lead_image, aliases: %i[lead_image] do
    edition
    image
  end
end
