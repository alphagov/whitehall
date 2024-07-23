FactoryBot.define do
  factory :content_block_version, class: "ContentObjectStore::ContentBlockVersion" do
    event { "created" }
    item {}
    whodunnit {}
  end
end
