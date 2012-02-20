FactoryGirl.define do
  factory :organisation_type do
    sequence(:name) { |n| "Organisation Type #{n}" }
  end

  factory :ministerial_organisation_type, parent: :organisation_type do
    name "Ministerial Department"
  end
end