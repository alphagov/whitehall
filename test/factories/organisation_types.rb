FactoryGirl.define do
  factory :organisation_type do
    sequence(:name) { |n| "Organisation Type #{n}" }
    analytics_prefix "T"
  end

  factory :ministerial_organisation_type, parent: :organisation_type do
    name "Ministerial Department"
  end
end
