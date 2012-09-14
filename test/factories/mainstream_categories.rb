FactoryGirl.define do
  factory :mainstream_category do
    title "Mainstream category"
    identifier  "https://contentapi.production.alphagov.co.uk/tags/mainstream-parent-category%2Fmainstream-category.json"
    parent_title "Mainstream parent category"
  end
end