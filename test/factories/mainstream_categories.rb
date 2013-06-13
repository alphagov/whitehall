FactoryGirl.define do
  factory :mainstream_category do
    sequence(:title) { |index| "Mainstream category #{index}" }
    sequence(:slug) { |index| "subsubcategory-#{index}" }
    description "Mainstream category description"
    parent_title "Mainstream parent category"
    parent_tag "business/tax"
  end
end
