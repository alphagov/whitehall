FactoryGirl.define do
  factory :document_collection_group do
    sequence(:heading) { |i| "Group #{i}" }
    body 'Group body text'
  end
end
