FactoryBot.define do
  factory :navigation_edition do
    navigation { FactoryBot.create(:navigation) }
    edition { FactoryBot.create(:draft_standard_edition) }
  end
end
