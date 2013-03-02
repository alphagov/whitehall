FactoryGirl.define do
  factory :statistical_data_set, class: StatisticalDataSet, parent: :edition do
    title   "statistical-data-set-title"
    body    "statistical-data-set-body"
    summary "statistical-data-set-summary"
    publication_date { 10.days.ago }
  end

  factory :imported_statistical_data_set, parent: :statistical_data_set, traits: [:imported] do
    access_limited false
  end
  factory :draft_statistical_data_set, parent: :statistical_data_set, traits: [:draft]
  factory :submitted_statistical_data_set, parent: :statistical_data_set, traits: [:submitted]
  factory :rejected_statistical_data_set, parent: :statistical_data_set, traits: [:rejected]
  factory :published_statistical_data_set, parent: :statistical_data_set, traits: [:published] do
    first_published_at { 2.days.ago }
  end
  factory :deleted_statistical_data_set, parent: :statistical_data_set, traits: [:deleted]
  factory :archived_statistical_data_set, parent: :statistical_data_set, traits: [:archived] do
    first_published_at { 2.days.ago }
  end
  factory :scheduled_statistical_data_set, parent: :statistical_data_set, traits: [:scheduled]
end
