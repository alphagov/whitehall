FactoryGirl.define do
  factory :organisation_type do
    sequence(:name) { |n| "Organisation Type #{n}" }
    analytics_prefix "T"
  end

  factory :ministerial_organisation_type, parent: :organisation_type do
    name "Ministerial Department"
  end

  factory :non_ministerial_organisation_type, parent: :organisation_type do
    name "Non-ministerial department"
  end

  factory :public_corporation_organisation_type, parent: :organisation_type do
    name "Public corporation"
  end
end
