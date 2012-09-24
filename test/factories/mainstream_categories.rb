FactoryGirl.define do
  factory :mainstream_category do
    title "Mainstream category"
    sequence(:identifier) { |n| "http://example.com/tags/category-#{n}.json" }
    parent_title "Mainstream parent category"
  end
end
