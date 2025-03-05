FactoryBot.define do
  factory :links_report do
    links { %w[http://link1.com http://link1.com] }
    edition { create(:draft_edition) }
  end
end
