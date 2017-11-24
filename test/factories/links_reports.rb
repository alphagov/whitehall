FactoryBot.define do
  factory :links_report do
    links %w(http://link1.com http://link1.com)
    link_reportable { create(:draft_edition) }
  end
end
