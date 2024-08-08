FactoryBot.define do
  factory :content_block_edition_organisation, class: "ContentObjectStore::ContentBlock::EditionOrganisation" do
    edition {}
    organisation {}
  end
end
