FactoryGirl.define do
  factory :mainstream_category do
    title "Mainstream category"
    sequence(:slug) { |n| "subsubcategory-#{n}" }
    description "Mainstream category description"
    parent_title "Mainstream parent category"
    parent_tag "business/tax"
  end
end
