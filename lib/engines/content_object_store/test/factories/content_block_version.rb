FactoryBot.define do
  factory :content_block_version, class: "ContentObjectStore::ContentBlock::Version" do
    event { "created" }
    item {}
    whodunnit {}
  end
end
