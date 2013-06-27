FactoryGirl.define do
  factory :about_page do
    sequence(:name) { |index| "about-page-#{index}" }
    read_more_link_text 'Read more'
    summary 'Summary'
    body 'Body'
  end
end
